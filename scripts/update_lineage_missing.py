#!/usr/bin/env python3

import json
import os
import gzip
import csv
import argparse

# # cut -d, -f2 samples.csv | taxonkit name2taxid -r > name2taxid.txt
# cat name2taxid.txt | taxonkit lineage -i 2 -R > samples.lineage.txt
# this one has 3 columns, with SPECIESIN as first column

def load_lineages(fh):
    lineages = {}
    lineages_name = {}
    for line in fh:
        
        row = line.strip().split("\t")
        if len(row) < 3:
            continue

        taxid = row[1]
        name = row[0]
        lineages[taxid] = {}
        lineages_name[name] = taxid
        names = row[4].split(";")
        ranknames = row[5].split(";")
        for i in range(0, len(names)):
            lineages[taxid][ranknames[i]] = names[i]
    return (lineages,lineages_name)

def load_samples(fh):
    samples = []
    reader = csv.DictReader(fh)
    for row in reader:
        samples.append(row)
    return samples

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Process Samples and look for missing data",
                                    epilog='Example: update_lineage_missing.py')
    parser.add_argument("--samples", default="samples.csv", help="samples.csv file for fungi5k")
    parser.add_argument("--lineage", default="samples.lineage.txt", 
                        help="samples.lineage.txt file by running 'cut -d, -f2 samples.csv | taxonkit name2taxid -r | taxonkit lineage -i 2 -c -R > samples.lineage.txt'")

    parser.add_argument('-v','--debug', help='Debugging output', action='store_true')

    parser.add_argument("-o","--outfile", default='samples.lineage_fixed.csv', 
                        help="Output file")
    
    args = parser.parse_args()
    with open(args.samples,"r") as fh,open(args.lineage,"r") as linfh, open(args.outfile, "w",newline="") as outfh:

        (lineage,lineage_name) = load_lineages(linfh)
        csvout = csv.writer(outfh)
        reader = csv.reader(fh)

        header = next(reader)
        header2col = {}
        for i,h in enumerate(header):
            header2col[h] = i     
        csvout.writerow(header)
        
        for row in reader:
            taxid = row[header2col['NCBI_TAXONID']]
            taxonomyrange = []
            #row[5:13]
            lastname = ""
            
            if not taxid:                
                speciesin=row[header2col['SPECIESIN']]
                print(speciesin)
                taxid = lineage_name[speciesin]
            lastname = lineage[taxid]['kingdom']
            for name in ['phylum','subphylum','class','subclass','order','family','genus','species']:
                if name not in lineage[taxid]:
                    if args.debug:
                        print("Missing",taxid,name)
                    taxonomyrange.append("")
                else:
                    taxonomyrange.append(lineage[taxid][name])
                    lastname = lineage[taxid][name]
            row[6:14] = taxonomyrange
            csvout.writerow(row)
