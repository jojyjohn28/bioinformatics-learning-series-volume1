## 🐛 COI (Cytochrome c oxidase subunit I) Workflow – Paired-End

Marker: Metazoans (Animals)
Primers: Leray primers (mlCOIintF / jgHCO2198)

```bash
##############################################
# COI QIIME2 Workflow – Paired-End
##############################################

# 1. Import sequences
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest_coi.csv \
  --output-path demux_coi.qza \
  --input-format PairedEndFastqManifestPhred33V2

# 2. Trim primers
# Forward: GGWACWGGWTGAACWGTWTAYCCYCC
# Reverse: TAIACYTCIGGRTGICCRAARAAYCA
qiime cutadapt trim-paired \
  --i-demultiplexed-sequences demux_coi.qza \
  --p-front-f GGWACWGGWTGAACWGTWTAYCCYCC \
  --p-front-r TAIACYTCIGGRTGICCRAARAAYCA \
  --o-trimmed-sequences trimmed_coi.qza

# 3. Quality summary
qiime demux summarize \
  --i-data trimmed_coi.qza \
  --o-visualization trimmed_coi.qzv

# 4. DADA2 denoising
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs trimmed_coi.qza \
  --p-trunc-len-f 200 \
  --p-trunc-len-r 200 \
  --o-table table_coi.qza \
  --o-representative-sequences repseq_coi.qza \
  --o-denoising-stats stats_coi.qza

# 5. Summaries
qiime feature-table summarize \
  --i-table table_coi.qza \
  --o-visualization table_coi.qzv

qiime metadata tabulate \
  --m-input-file stats_coi.qza \
  --o-visualization stats_coi.qzv

# 6. Assign taxonomy (MIDORI or BOLD)
qiime feature-classifier classify-sklearn \
  --i-classifier midori_classifier.qza \
  --i-reads repseq_coi.qza \
  --o-classification taxonomy_coi.qza

# 7. Filter non-metazoans
qiime taxa filter-table \
  --i-table table_coi.qza \
  --i-taxonomy taxonomy_coi.qza \
  --p-include k__Animalia \
  --o-filtered-table table_coi_filtered.qza

qiime taxa filter-seqs \
  --i-sequences repseq_coi.qza \
  --i-taxonomy taxonomy_coi.qza \
  --p-include k__Animalia \
  --o-filtered-sequences repseq_coi_filtered.qza

# 8. Phylogenetic tree
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences repseq_coi_filtered.qza \
  --o-alignment aligned_coi.qza \
  --o-masked-alignment masked_coi.qza \
  --o-tree unrooted_coi.qza \
  --o-rooted-tree rooted_coi.qza

# 9. Exporting files
qiime tools export --input-path table_coi_filtered.qza --output-path export_coi_table
qiime tools export --input-path taxonomy_coi.qza --output-path export_coi_taxonomy
qiime tools export --input-path rooted_coi.qza --output-path export_coi_tree
qiime tools export --input-path repseq_coi_filtered.qza --output-path export_coi_repseq

```
