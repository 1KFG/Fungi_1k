#!/usr/bin/env python3

import os
import csv
import gzip

outdir = 'bigquery'
def merops(indir="results/function/merops",force=False):
    # load MEROPS data
    outfile = os.path.join(outdir,os.path.basename(indir) + ".csv")
    if (os.path.exists(outfile) or os.path.exists(outfile + ".gz") )and not force:
        return 
    with open(outfile, "w", newline='') as of:
        writer = csv.writer(of)
        writer.writerow(['protein_id','merops_id','percent_identity','aln_length','mismatches','gap_openings','q_start','q_end',
                        's_start','s_end', 'evalue', 'bitscore'])
        for file in os.listdir(indir):
            if file.endswith(".blasttab.gz"):
                with gzip.open(os.path.join(indir,file), "rt") as infh:
                    reader = csv.reader(infh, delimiter='\t')
                    for row in reader:
                        writer.writerow(row)

def cazy_overview(indir="results/function/cazy",force=False):
    # load CAZY data
    outfile = os.path.join(outdir,os.path.basename(indir) + ".overview.csv")
    if (os.path.exists(outfile) or os.path.exists(outfile + ".gz") ) and not force:
        return
    with open(outfile, "w", newline='') as of:
        writer = csv.writer(of)
        # Gene_ID	EC	cazyme_fam	sub_fam	diamond_fam	Substrate	#ofTools
        writer.writerow(['protein_id','EC','cazyme_fam','sub_fam','diamond_fam','substrate','toolcount'])
        for spdir in os.listdir(indir):
            infile = os.path.join(indir,spdir,'overview.tsv.gz')
            if os.path.exists(infile):
                with gzip.open(infile, "rt") as infh:
                    reader = csv.reader(infh, delimiter='\t')
                    next(reader)
                    for row in reader:
                        writer.writerow(row)

def cazy_hmm(indir="results/function/cazy",force=False):
    # load CAZY data
    outfile = os.path.join(outdir,os.path.basename(indir) + ".cazymes_hmm.csv")
    if (os.path.exists(outfile) or os.path.exists(outfile + ".gz") ) and not force:
        return
    with open(outfile, "w", newline='') as of:
        writer = csv.writer(of)
        # HMM_Profile	Profile_Length	Gene_ID	Gene_Length	Evalue	Profile_Start	Profile_End	Gene_Start	Gene_End	Coverage
        writer.writerow(['HMM_id','profile_length','protein_id','protein_length','evalue',
                        'q_start','q_end','s_start','s_end', 'coverage'])
        for spdir in os.listdir(indir):
            infile = os.path.join(indir,spdir,'cazymes.tsv.gz')
            if os.path.exists(infile):
                with gzip.open(infile, "rt") as infh:
                    reader = csv.reader(infh, delimiter='\t')
                    next(reader)
                    for row in reader:
                        writer.writerow(row)

def signalp(indir="results/function/signalp",force=False):
    # load signalp data
    outfile = os.path.join(outdir,os.path.basename(indir) + ".signal_peptide.csv")
    if (os.path.exists(outfile) or os.path.exists(outfile + ".gz") ) and not force:
        return
    with open(outfile, "w", newline='') as of:
        writer = csv.writer(of)
        # HMM_Profile	Profile_Length	Gene_ID	Gene_Length	Evalue	Profile_Start	Profile_End	Gene_Start	Gene_End	Coverage
        writer.writerow(['protein_id','peptide_start','peptide_end','probability'])
        for file in os.listdir(indir):
            if file.endswith(".signalp.gff3.gz"):
                with gzip.open(os.path.join(indir,file), "rt") as infh:
                    reader = csv.reader(infh, delimiter='\t')
                    for row in reader:
                        if row[0].startswith('#'):
                            continue
                        id = row[0].split(' ')[0]
                        newrow = [id, row[3], row[4], row[5]]
                        writer.writerow(newrow)

def tmhmm(indir="results/function/tmhmm",force=False):
    outfile = os.path.join(outdir,os.path.basename(indir) + ".csv")
    if (os.path.exists(outfile) or os.path.exists(outfile + ".gz") ) and not force:
        return
    with open(outfile, "w", newline='') as of:
        writer = csv.writer(of)
        writer.writerow(['protein_id','len','ExpAA','First60','PredHel','Topology'])
        for file in os.listdir(indir):
            if file.endswith(".tmhmm_short.tsv.gz"):
                with gzip.open(os.path.join(indir,file), "rt") as infh:
                    reader = csv.reader(infh, delimiter='\t')
                    for row in reader:
                        if row[0].startswith('#'):
                            continue
                        newrow = [id]
                        for n in row[1:]:
                            (key,value) = n.split('=')
                            newrow.append(value)
                        if newrow[-2] == '0':
                            continue

                        writer.writerow(newrow)

def wolfpsort(indir="results/function/wolfpsort",force=False,onlybest=True):
    outfile = os.path.join(outdir,os.path.basename(indir) + ".csv")
    if (os.path.exists(outfile) or os.path.exists(outfile + ".gz") ) and not force:
        return
    with open(outfile, "w", newline='') as of:
        writer = csv.writer(of)
        writer.writerow(['protein_id','localization','score'])
        for file in os.listdir(indir):
            if file.endswith(".wolfpsort.results.txt.gz"):
                with gzip.open(os.path.join(indir,file), "rt") as infh:                    
                    for line in infh:
                        if line.startswith('#'):
                            continue
                        (id,resultstr) = line.strip().split(' ',1)
                        results = resultstr.split(', ')
                        for scoring in results:
                            (code,score) = scoring.split(' ')                        
                            newrow = [id,code,score]                        
                            writer.writerow(newrow)
                            if onlybest:
                                break


def targetp(indir="results/function/targetp",force=False):
    print('not running yet')

def kegg(indir="results/function/kegg",force=False):
    print('not running yet')

def busco(indir="results/stats/busco",force=False):
    print('not running yet')

def pfam(indir="results/function/pfam",force=False):
    outfile = os.path.join(outdir,os.path.basename(indir) + ".csv")
    if (os.path.exists(outfile) or os.path.exists(outfile + ".gz") ) and not force:
        return
    with open(outfile, "w", newline='') as of:
        writer = csv.writer(of)
        writer.writerow(['protein_id','pfam_id','full_seq_e_value','full_seq_score',
                        'full_seq_bias','domain_num','domain_num_of','domain_c_evalue',
                        'domain_i_evalue','domain_score','domain_bias','hmm_from',
                        'hmm_to','ali_from','ali_to','env_from','env_to','acc'])
        for file in os.listdir(indir):
            if file.endswith(".domtblout.gz"):
                with gzip.open(os.path.join(indir,file), "rt") as infh:
                    for line in infh:
                        if line.startswith('#'):
                            continue
                        row = line.strip().split(None,22)
                        newrow = [row[3],row[0]]
                        newrow.extend(row[6:-1])
                        writer.writerow(newrow)
    
merops()
cazy_overview()
cazy_hmm()
signalp()
pfam()
#kegg()

tmhmm()
wolfpsort()
#busco()
#targetp()
