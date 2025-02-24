#!/usr/bin/bash -l
#SBATCH -p short -C ryzen --mem 128gb -c 16 -N 1 -n 1 --out logs/load_functionDB.log
module load duckdb
DBDIR=functionalDB
DBNAME=function
mkdir -p $DBDIR
# build species table
duckdb -c "CREATE TABLE IF NOT EXISTS species AS SELECT * FROM read_csv_auto('samples.csv')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_species_locustag ON species(LOCUSTAG)" $DBDIR/$DBNAME.duckdb

# build asm stats table
duckdb -c "CREATE TABLE IF NOT EXISTS asm_stats AS SELECT * FROM read_csv_auto('bigquery/asm_stats.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_asmstats_locustag ON asm_stats(LOCUSTAG)" $DBDIR/$DBNAME.duckdb

# build proteins
duckdb -c "CREATE TABLE IF NOT EXISTS gene_proteins AS SELECT * FROM read_csv_auto('bigquery/gene_proteins.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_gene_proteins ON gene_proteins(gene_id,transcript_id)" $DBDIR/$DBNAME.duckdb

# Add tRNA
duckdb -c "CREATE TABLE IF NOT EXISTS gene_trna AS SELECT * FROM read_csv_auto('bigquery/gene_trnas.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_gene_trna ON gene_trna(gene_id)" $DBDIR/$DBNAME.duckdb

# Add transcripts
duckdb -c "CREATE TABLE IF NOT EXISTS gene_transcripts AS SELECT * FROM read_csv_auto('bigquery/gene_transcripts.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_transcripts ON gene_transcripts(gene_id,transcript_id)" $DBDIR/$DBNAME.duckdb

# build gene info table
duckdb -c "CREATE TABLE IF NOT EXISTS gene_info AS SELECT * FROM read_csv_auto('bigquery/gene_info.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_gene_info ON gene_info(gene_id)" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_gene_info_LOCUS ON gene_info(LOCUSTAG)" $DBDIR/$DBNAME.duckdb

# build signalp table
duckdb -c "CREATE TABLE IF NOT EXISTS signalp AS SELECT * FROM read_csv_auto('bigquery/signalp.signal_peptide.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_signalp_proteinid ON signalp(protein_id)" $DBDIR/$DBNAME.duckdb


# build merops table
duckdb -c "CREATE TABLE IF NOT EXISTS merops AS SELECT * FROM read_csv_auto('bigquery/merops.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_merops_proteinid ON merops(protein_id)" $DBDIR/$DBNAME.duckdb

# build CAZY table
duckdb -c "CREATE TABLE IF NOT EXISTS cazy_overview AS SELECT * FROM read_csv_auto('bigquery/cazy.overview.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_cazy_overview_proteinid ON cazy_overview(protein_id)" $DBDIR/$DBNAME.duckdb

# build CAZY domains table
duckdb -c "CREATE TABLE IF NOT EXISTS cazy AS SELECT * FROM read_csv_auto('bigquery/cazy.cazymes_hmm.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_cazy_proteinid ON cazy(protein_id)" $DBDIR/$DBNAME.duckdb

# build Pfam domains table
duckdb -c "CREATE TABLE IF NOT EXISTS pfam AS SELECT * FROM read_csv_auto('bigquery/pfam.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_pfam_proteinid ON pfam(protein_id)" $DBDIR/$DBNAME.duckdb

# Add funguild
duckdb -c "CREATE TABLE IF NOT EXISTS funguild AS SELECT * FROM read_csv_auto('bigquery/species_funguild.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_funguild_locustag ON funguild(species_prefix)" $DBDIR/$DBNAME.duckdb

# Add codon freq
duckdb -c "CREATE TABLE IF NOT EXISTS codon_frequency AS SELECT * FROM read_csv_auto('bigquery/codon_freq.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_codonfreq_locustag ON codon_frequency(species_prefix)" $DBDIR/$DBNAME.duckdb

# Add AA freq
duckdb -c "CREATE TABLE IF NOT EXISTS aa_frequency AS SELECT * FROM read_csv_auto('bigquery/aa_freq.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_aa_locustag ON aa_frequency(species_prefix)" $DBDIR/$DBNAME.duckdb

# Add gene distance
duckdb -c "CREATE TABLE IF NOT EXISTS gene_pairwise_distances AS SELECT * FROM read_csv_auto('bigquery/gene_pairwise_distances.csv.gz')" $DBDIR/$DBNAME.duckdb
duckdb -c "CREATE INDEX IF NOT EXISTS idx_gene_pw_locustag ON gene_pairwise_distances(species_prefix)" $DBDIR/$DBNAME.duckdb
