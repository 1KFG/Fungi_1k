#!/usr/bin/bash -l
#SBATCH -p short -c 10 --mem 48gb -N 1 -n 1 --out logs/tmhmm.%a.log
module load tmhmm

CPU=1
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
FILEBATCH=10 # how many files to process at a time
INDIR=$(realpath input)
OUTDIR=results/function/tmhmm/
mkdir -p $OUTDIR
OUTDIR=$(realpath $OUTDIR)
sampset=sampleset.txt
if [ ! -s $sampset ]; then
	ls -U $INDIR | sort > $sampset
fi
sampset=$(realpath sampleset.txt)
MAX=$(wc -l $sampset | awk '{print $1}')
START=$(perl -e "print 1 + (($N - 1) * $FILEBATCH)")
END=$(perl -e "print ($N * $FILEBATCH) - 1")
if [ $START -gt $MAX ]; then
	echo "$START too big for $MAX"
	exit
elif [ $END -gt $MAX ]; then
	END=$MAX
fi
echo "running $START - $END"

runtmhmm() {
	INFILE=$1
	NAME=$(basename $INFILE _proteins_2021-08-30.fasta)
	echo "$NAME"
	if [ ! -f $OUTDIR/${NAME}.tmhmm_results.tsv.gz ]; then
		time tmhmm --noplot < $INDIR/$INFILE > $OUTDIR/${NAME}.tmhmm_results.tsv
		pigz  $OUTDIR/${NAME}.tmhmm_results.tsv
	fi

}
export -f runtmhmm 
export INDIR OUTDIR
pushd $SCRATCH
parallel -j $CPU runtmhmm {} ::: $(sed -n ${START},${END}p $sampset)
