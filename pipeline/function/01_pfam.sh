#!/usr/bin/bash -l
#SBATCH -p epyc -N 1 -n 1 -c 2 --mem 2gb --out logs/pfam.%a.log

CPU=2
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

module load hmmer/3.4
module load db-pfam
module load workspace/scratch
INPUT=input
OUTDIR=results/function/pfam
mkdir -p $OUTDIR

IN=$(ls -U $INPUT/*.fasta | sed -n ${N}p)
PREFIX=$(basename $IN _proteins_2021-08-30.fasta)
rsync -a $PFAM_DB/Pfam-A.hmm* $SCRATCH/
time hmmscan --cut_ga --cpu $CPU \
    --domtblout $OUTDIR/${PREFIX}.domtblout \
    --tblout $OUTDIR/${PREFIX}.tblout \
    $SCRATCH/Pfam-A.hmm $IN | gzip -c > $OUTDIR/${PREFIX}.$N.log.gz
pigz $OUTDIR/${PREFIX}.domtbl ${OUTDIR}/${PREFIX}.tblout
