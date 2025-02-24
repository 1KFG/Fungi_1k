#!/usr/bin/bash -l
#SBATCH -p short -c 4 --mem 16gb --out logs/trnascan.%a.log

module load trnascan-se

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

OUTDIR=results/tRNA
INDIR=genomes
SAMPLES=samples.csv
EXT=fasta
mkdir -p $OUTDIR
IFS=,
tail -n +2 $SAMPLES | sed -n ${N}p | while read PREFIX SPECIESIN REST
do
    INPUT=$INDIR/$PREFIX.$EXT
    if [ ! -s $INPUT ]; then
        echo "no input genome file $INPUT"
        continue
    fi
    tRNAscan-SE --thread $CPU -E -o $OUTDIR/$PREFIX.trnascan $INPUT
    ./scripts/trnascan2gff3.pl --input $OUTDIR/$PREFIX.trnascan > $OUTDIR/$PREFIX.trnascan.gff3
done