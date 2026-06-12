## 🧰 🐟 12S MiFish Workflow (Paired-End)

Marker: Vertebrates (eDNA)
Primers: MiFish-U/E (Miya et al., 2015)

```bash
##############################################
# 12S (MiFish) QIIME2 Workflow – Paired-End
##############################################

# 1. Import sequences
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest_12s.csv \
  --output-path demux_12s.qza \
  --input-format PairedEndFastqManifestPhred33V2

# 2. Trim primers (MiFish)
# Forward: GTCGGTAAAACTCGTGCCAGC
# Reverse: CATAGTGGGGTATCTAATCCCAGTTTG
qiime cutadapt trim-paired \
  --i-demultiplexed-sequences demux_12s.qza \
  --p-front-f GTCGGTAAAACTCGTGCCAGC \
  --p-front-r CATAGTGGGGTATCTAATCCCAGTTTG \
  --o-trimmed-sequences trimmed_12s.qza

# 3. Quality summary
qiime demux summarize \
  --i-data trimmed_12s.qza \
  --o-visualization trimmed_12s.qzv

# 4. DADA2 denoising
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs trimmed_12s.qza \
  --p-trunc-len-f 150 \
  --p-trunc-len-r 150 \
  --o-table table_12s.qza \
  --o-representative-sequences repseq_12s.qza \
  --o-denoising-stats stats_12s.qza

# 5. Summaries
qiime feature-table summarize \
  --i-table table_12s.qza \
  --o-visualization table_12s.qzv

qiime metadata tabulate \
  --m-input-file stats_12s.qza \
  --o-visualization stats_12s.qzv

# 6. Assign taxonomy (MitoFish recommended)
qiime feature-classifier classify-sklearn \
  --i-classifier mitofish_classifier.qza \
  --i-reads repseq_12s.qza \
  --o-classification taxonomy_12s.qza

# 7. Filter non-vertebrates
qiime taxa filter-table \
  --i-table table_12s.qza \
  --i-taxonomy taxonomy_12s.qza \
  --p-include Vertebrata \
  --o-filtered-table table_12s_filtered.qza

qiime taxa filter-seqs \
  --i-sequences repseq_12s.qza \
  --i-taxonomy taxonomy_12s.qza \
  --p-include Vertebrata \
  --o-filtered-sequences repseq_12s_filtered.qza

# 8. Phylogenetic tree
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences repseq_12s_filtered.qza \
  --o-alignment aligned_12s.qza \
  --o-masked-alignment masked_12s.qza \
  --o-tree unrooted_12s.qza \
  --o-rooted-tree rooted_12s.qza

# 9. Exporting files
qiime tools export --input-path table_12s_filtered.qza --output-path export_12s_table
qiime tools export --input-path taxonomy_12s.qza --output-path export_12s_taxonomy
qiime tools export --input-path rooted_12s.qza --output-path export_12s_tree
qiime tools export --input-path repseq_12s_filtered.qza --output-path export_12s_repseq
```
