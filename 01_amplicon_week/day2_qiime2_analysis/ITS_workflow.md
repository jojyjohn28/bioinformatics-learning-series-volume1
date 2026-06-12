## 🍄 ITS (ITS1 / ITS2) Workflow – Paired-End

Marker: Fungi
Primers:

ITS1F / ITS2

ITS3 / ITS4

```bash
##############################################
# ITS (Fungal) QIIME2 Workflow – Paired-End
##############################################

# 1. Import sequences
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest_its.csv \
  --output-path demux_its.qza \
  --input-format PairedEndFastqManifestPhred33V2

# 2. Trim primers
# Common ITS primers:
# ITS1F: CTTGGTCATTTAGAGGAAGTAA
# ITS2: GCTGCGTTCTTCATCGATGC
qiime cutadapt trim-paired \
  --i-demultiplexed-sequences demux_its.qza \
  --p-front-f CTTGGTCATTTAGAGGAAGTAA \
  --p-front-r GCTGCGTTCTTCATCGATGC \
  --o-trimmed-sequences trimmed_its.qza

# 3. Quality summary
qiime demux summarize \
  --i-data trimmed_its.qza \
  --o-visualization trimmed_its.qzv

# 4. DADA2 denoising (ITS very variable → often lower truncation)
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs trimmed_its.qza \
  --p-trunc-len-f 200 \
  --p-trunc-len-r 180 \
  --o-table table_its.qza \
  --o-representative-sequences repseq_its.qza \
  --o-denoising-stats stats_its.qza

# 5. Summaries
qiime feature-table summarize \
  --i-table table_its.qza \
  --o-visualization table_its.qzv

qiime metadata tabulate \
  --m-input-file stats_its.qza \
  --o-visualization stats_its.qzv

# 6. Taxonomy (UNITE database)
qiime feature-classifier classify-sklearn \
  --i-classifier unite_classifier.qza \
  --i-reads repseq_its.qza \
  --o-classification taxonomy_its.qza

# 7. Keep only fungi (remove plants, protists, bacteria)
qiime taxa filter-table \
  --i-table table_its.qza \
  --i-taxonomy taxonomy_its.qza \
  --p-include k__Fungi \
  --o-filtered-table table_its_filtered.qza

qiime taxa filter-seqs \
  --i-sequences repseq_its.qza \
  --i-taxonomy taxonomy_its.qza \
  --p-include k__Fungi \
  --o-filtered-sequences repseq_its_filtered.qza

# 8. Phylogenetic tree (ITS is not ideal for phylogeny, but still possible)
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences repseq_its_filtered.qza \
  --o-alignment aligned_its.qza \
  --o-masked-alignment masked_its.qza \
  --o-tree unrooted_its.qza \
  --o-rooted-tree rooted_its.qza

# 9. Exporting files
qiime tools export --input-path table_its_filtered.qza --output-path export_its_table
qiime tools export --input-path taxonomy_its.qza --output-path export_its_taxonomy
qiime tools export --input-path rooted_its.qza --output-path export_its_tree
qiime tools export --input-path repseq_its_filtered.qza --output-path export_its_repseq
```
