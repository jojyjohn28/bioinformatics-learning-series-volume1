## 18S rRNA Metabarcoding Workflow (QIIME2)

Prepared for AmpliconWeek_2025 GitHub Project

18S rRNA metabarcoding is widely used to profile eukaryotic microbial communities, especially protists, plankton, and microeukaryotes in environmental samples such as sediments, water, and soils.

This workflow demonstrates a full QIIME2 pipeline for paired-end Illumina 18S amplicons, including installation, import, quality control, denoising, classifier training, taxonomic assignment, contamination removal, phylogenetic analyses, and diversity analyses.

#### 📁 1. Folder Setup & Input Data Preparation

Naming rules:

✔Lowercase letters and underscore only

✔Avoid spaces

✔Use consistent sample naming

✔Validate .gz files before using:

Use 7zip Test or QIIME2 import will fail.

#### 📥 2. Check FASTQ Read Counts (Optional but Highly Recommended)

Uneven read counts between R1/R2 cause import errors.

```bash
for f in *.fastq.gz; do r=$(( $(zcat $f | wc -l | tr -d '[:space:]') / 4 )); echo $r $f; done
```

#### 🚀 3. Import Paired-End 18S Raw Sequences

Your raw data must follow CASAVA 1.8 naming format:

<sampleID>\_<barcode>\_L001_R1_001.fastq.gz

```bash
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path casava-18-paired-end-demultiplexed \
  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
  --output-path demux-paired-end.qza \
  --verbose &> qiime_demux_summarize.log
```

--verbose logs run details for troubleshooting.

#### 🔍 4. Summarize & Validate Imported Data

```bash
qiime demux summarize \
  --i-data demux-paired-end.qza \
  --o-visualization demux-paired-end.qzv \
  --verbose
```

Validate:

```bash
qiime tools validate demux-paired-end.qza
```

Upload .qzv to https://view.qiime2.org to inspect quality.

#### 🧼 5. Denoising With DADA2

**18S amplicons from sediments often require 150 bp truncation.**

```bash
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux-paired-end.qza \
  --p-trunc-len-f 150 \
  --p-trim-left-r 0 \
  --p-trunc-len-r 150 \
  --o-representative-sequences rep-seqs-dada2.qza \
  --o-table table-dada2.qza \
  --o-denoising-stats stats-dada2.qza \
  --verbose &> DADA2_denoising.log
```

💡 If you get Killed, check memory errors:

```bash
dmesg -T | grep -E -i -B100 'killed process'
```

#### 📊 6. Summarize DADA2 Outputs

Denoising stats

```bash
qiime metadata tabulate \
  --m-input-file stats-dada2.qza \
  --o-visualization stats-dada2.qzv
```

Representative sequences

```bash
qiime feature-table tabulate-seqs \
  --i-data rep-seqs-dada2.qza \
  --o-visualization rep_seqs.qzv
```

Feature table

```bash
qiime feature-table summarize \
  --i-table table-dada2.qza \
  --o-visualization table.qzv
```

#### 🧬 7. Train an 18S Classifier (SILVA 132)

SILVA 132 contains high-quality 18S rRNA sequences and taxonomy — ideal for microeukaryotic studies.

```bash
wget https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_132_release.zip
unzip Silva_132_release.zip
rm Silva_132_release.zip
```

Import reference sequences:

```bash
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path rep_set/rep_set_18S_only/99/silva_132_99_18S.fna \
  --output-path 99_otus_18S.qza
```

Import taxonomy:

```bash
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path taxonomy/18S_only/99/majority_taxonomy_7_levels.txt \
  --output-path 99_otus_18S_taxonomy.qza
```

Train:

```bash
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads 99_otus_18S.qza \
  --i-reference-taxonomy 99_otus_18S_taxonomy.qza \
  --o-classifier classifier.qza
```

#### 🏷 8. Assign Taxonomy

```bash
qiime feature-classifier classify-sklearn \
  --i-classifier classifier.qza \
  --i-reads rep-seqs-dada2.qza \
  --o-classification taxonomy.qza
```

Tabulate:

```bash
qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv
```

#### 🚫 9. Remove Unwanted Taxa (e.g., Fungi)

18S primers can amplify fungi — remove them:

```bash
qiime taxa filter-table \
  --i-table table-dada2.qza \
  --i-taxonomy taxonomy.qza \
  --p-exclude "Fungi" \
  --o-filtered-table taxonomy_filtered.qza
```

#### 🌳 10. Build a Phylogenetic Tree

```bash
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs-dada2.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza \
  --verbose &> phylogenetic_tree_generation.log
```

#### 📤 11. Export Files for Downstream Analysis (18S)

These exported files will produce:

● feature-table.tsv

● taxonomy.tsv

● rooted-tree.nwk

● dna-sequences.fasta

Exactly what Microeco, phyloseq, vegan, and other R tools need.

🗂 Export Feature Table

```bash
qiime tools export \
  --input-path taxonomy_filtered.qza \
  --output-path export_18s_table

# Convert BIOM to TSV
biom convert \
  -i export_18s_table/feature-table.biom \
  -o export_18s_table/feature-table.tsv \
  --to-tsv
```

🧬 Export Taxonomy

```bash
qiime tools export \
  --input-path taxonomy.qza \
  --output-path export_18s_taxonomy
```

🌳 Export Rooted Tree (Newick Format)

```bash
qiime tools export \
  --input-path rooted-tree.qza \
  --output-path export_18s_tree
```

🧾 Export Representative Sequences (FASTA)

```bash
qiime tools export \
  --input-path rep-seqs-dada2.qza \
  --output-path export_18s_repseq
```

#### 🔚 End of Workflow

You now have:

✔ Representative sequences
✔ Feature table
✔ Taxonomy
✔ Phylogenetic tree
✔ Alpha & Beta diversity results
✔ Rarefaction curves

These outputs can now be used in microeco, phyloseq, or other R-based ecological analyses.
