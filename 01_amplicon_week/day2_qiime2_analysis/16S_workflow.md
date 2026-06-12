**Amplicon Week — Day 2: QIIME2 Setup, Importing Data & Classifier Training!**

#### 16S amplicon sequencing and analysis

Welcome to Day 2 of the Amplicon Sequencing & Metabarcoding Series (Dec 8–13).
Today’s focus is on the core processing pipeline using QIIME2, the most widely used platform for amplicon data analysis.

This post provides a general workflow that applies to:

16S rRNA (Bacteria & Archaea)

ITS (Fungi)

18S rRNA (Eukaryotes)

12S rRNA (Fish & vertebrate eDNA)

COI (DNA barcoding for animals & invertebrates)

We will demonstrate using 16S as the example, but all steps translate to other markers (with marker-specific primers & classifiers, linked in GitHub).

At the end of today’s post, you will be able to:

✔ Install QIIME2
✔ Import amplicon FASTQ files
✔ Remove primers
✔ Run DADA2 (denoising → ASVs)
✔ Build a phylogenetic tree
✔ Assign taxonomy
✔ Export data for R / Microeco

Let’s dive in.

#### 🧬 1. Installing QIIME2

for installation please visit day1 tutorial at https://jojyjohn28.github.io/blog/amplicon-day1/
or at https://github.com/jojyjohn28/AmpliconWeek_2025

#### 📁 2. Creating the Manifest File

QIIME2 needs a manifest file pointing to each sample’s FASTQ files.
A manifest file is a tab separated table with 3 columns with the following headers:
sample-id forward-absolute-filepath reverse-absolute-filepath
Example manifest file:

```ruby
sample-id,forward-absolute-filepath,reverse-absolute-filepath
S1,/path/raw/S1_R1.fastq.gz,/path/raw/S1_R2.fastq.gz
S2,/path/raw/S2_R1.fastq.gz,/path/raw/S2_R2.fastq.gz
S3,/path/raw/S3_R1.fastq.gz,/path/raw/S3_R2.fastq.gz
```

Some hints to make this file if you have many samples:

```bash
ls -1 /path/to/directory > /path/to/output/file_names.txt #To print the file name in directory
find /path/to/directory -type f -print > file_paths.txt #To print file paths in a directory
find /path/to/directory -type f -printf "%f\t%p\n" > file_names_and_paths.txt #To print file names and path in same file
```

#### 📥 3. Import FASTQ Into QIIME2

##### 3.1 🔁 Importing Paired-End Reads

When importing reads, QIIME2 requires two pieces of information:

**1️⃣ What kind of data you are importing?**

● SampleData[PairedEndSequencesWithQuality] → Paired-end reads
● SampleData[SequencesWithQuality] → Single-end reads

**2️⃣ What format are your FASTQ files in?**

Most Illumina sequencing uses:

● Phred33 (modern Illumina, MiSeq, NovaSeq)

● Phred64 (very old Illumina, rarely used now)

If your reads are from any modern platform, you should use Phred33.

```bash
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest.csv \
  --output-path demux-paired-end.qza \
  --input-format PairedEndFastqManifestPhred33V2
```

✔ Why we specify PairedEndFastqManifestPhred33V2:

● Tells QIIME2 each sample has two reads

● Uses filepaths from the manifest (absolute paths required)

● Ensures correct quality score interpretation

✔ Typical output

demux-paired-end.qza – your demultiplexed sequences in QIIME2 format.

##### 3.2 🔁 Importing Single-End Reads (For Some ITS, COI, Older Datasets)

If your data has only R1 reads, change both the type and input format:

```bash
qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path manifest_single.csv \
  --output-path demux-single-end.qza \
  --input-format SingleEndFastqManifestPhred33V2
```

**When to use single-end workflows?**

● Many ITS sequencing strategies (ITS1-only or ITS2-only)

● Some COI barcoding pipelines

● Older sequencing runs

● When reverse reads are too low-quality to use

##### ⚠️ Common Import Pitfalls & How to Avoid Them

❌ Error: “Filepath is not absolute”

All manifest file paths must be full paths (starting with /home/... or /project/...).

❌ Error: “fastq.gz not found”

Check for:

Hidden spaces

Wrong filenames

Case sensitivity (Linux is strict)

❌ Using the wrong Phred format

#### 3.3 🧪 Verifying the Import

Run:

```bash
qiime demux summarize \
  --i-data demux-paired-end.qza \
  --o-visualization demux-summary.qzv
```

Open at https://view.qiime2.org/

**You should see:**

● Number of samples

● Quality score plots

● Read counts per sample

#### ✂️ 4. Remove Primers Using Cutadapt

Example 16S V4 primers:

● Forward: GTGYCAGCMGCCGCGGTAA

● Reverse: GGACTACNVGGGTWTCTAAT

```bash
qiime cutadapt trim-paired \
  --i-demultiplexed-sequences demux-paired-end.qza \
  --p-front-f GTGYCAGCMGCCGCGGTAA \
  --p-front-r GGACTACNVGGGTWTCTAAT \
  --o-trimmed-sequences trimmed_demux.qza
```

**Why primer removal matters:**
✔ avoids false ASVs
✔ improves denoising
✔ ensures accurate taxonomy assignment

#### 📊 5. Check Quality & Determine Trimming Parameters

Look at:

Quality drop-off point

Read overlap requirement (≥20–30 bp)

Presence of residual primers

These determine your DADA2 truncation length in next step

```bash
qiime demux summarize \
  --i-data trimmed_demux.qza \
  --o-visualization trimmed_demux.qzv
```

#### 🔬 6. DADA2: Denoising → ASVs

Example settings (adjust based on your quality plot):

```bash
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs trimmed_demux.qza \
  --p-n-threads 32 \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 280 \
  --p-trunc-len-r 280 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza
```

-p-trim-left n, which trims off the first n bases of each sequence, and --p-trunc-len n which truncates each sequence at position n.  
To determine what values to pass for these two parameters, you should review the Interactive Quality Plot tab in the demux.qzv file that was generated by qiime demux summarize above command
Here --p-n-threads can be changed according to computation power, it is the long step with 32 thread on HPC it took, 30 minutes
**DADA2 outputs:**
● table.qza (ASV table)
● rep-seqs.qza (ASV sequences)
● denoising-stats.qza (diagnostics)

To view stats:

```bash
qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-stats.qzv
```

you now have the denoising summary, and this is exactly what you need to choose the best rarefaction (sampling) depth for diversity analyses in QIIME2 this will be useful in doing rarefraction and other analysis. For more details see best_rarefraction.md in github project repository:https://github.com/jojyjohn28/AmpliconWeek_2025

#### 🌳 7. Build a Phylogenetic Tree

Required for UniFrac and phylogenetic diversity:

```bash
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
```

#### 🧭 8 Assighn Taxonomy

Assigning taxonomy is one of the most critical steps in amplicon analysis.
The accuracy of your results depends heavily on choosing the appropriate taxonomic classifier and database.

QIIME2 uses a Naïve Bayes machine-learning classifier, which requires reference sequences and taxonomic labels. You can either:

1️⃣ Use a pre-trained classifier (recommended for general workflows)

— Fast
— Reliable
— Suitable for most datasets

2️⃣ Train your own classifier recommended when:

✔ Using uncommon primer sets
✔ Working with short reads
✔ Needing region-specific accuracy
✔ Using custom databases like GTDB, PR2 subsets, MIDORI, etc.

A step-by-step guide for training custom classifiers is included in the GitHub project:
👉 train_your_own_classifier.md
https://github.com/jojyjohn28/AmpliconWeek_2025
Recommended classifiers:
| Marker | Recommended Database | Notes |
| ------- | -------------------- | ---------------------------------------- |
| **16S** | SILVA 138.1, GTDB | SILVA most common; GTDB aligns with MAGs |
| **ITS** | UNITE | Fungal only |
| **18S** | PR2 (best), SILVA | PR2 great for protists |
| **12S** | MitoFish | Vertebrate eDNA |
| **COI** | MIDORI, BOLD | DNA barcoding |

Today we use SILVA 138 as example:

Download:

```bash
wget https://data.qiime2.org/2024.10/common/silva-138-99-nb-classifier.qza
```

Assign taxonomy:

```bash
qiime feature-classifier classify-sklearn \
  --i-classifier silva-138-99-nb-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza
```

This produces:

\_taxonomy.qza → machine-learning taxonomy table

\_taxonomy.qzv (after visualization) → interactive barplots and tables

#### 🚫 9. Remove contamination

After assigning taxonomy, it is essential to remove non-target sequences from your dataset.
These usually come from:
Host DNA;Environmental carryover;Mitochondria / chloroplasts;Off-target amplification;Universal primers binding to unintended taxa

The exact contaminants depend on which marker gene you are analyzing.
**16S (Bacteria + Archaea)**

Remove:

● Mitochondria (eukaryotic origin)

● Chloroplasts (from plants/algae)

● Eukaryotic sequences (if any appear)

Why?
16S primers sometimes amplify plant chloroplast 16S and mitochondrial 16S, especially in soil, water, or host-associated samples.
for more marker specific deatails please see contamination_removal.md in https://github.com/jojyjohn28/AmpliconWeek_2025

**📝 Summary Table: What to Filter**
| Marker | Keep | Remove |
| ------- | --------------------- | --------------------------------------------- |
| **16S** | Bacteria, Archaea | Mitochondria, chloroplasts, eukaryotes |
| **ITS** | Fungi | Plants, protists, bacteria, archaea |
| **18S** | Protists / eukaryotes | Bacteria, archaea, host DNA, fungi (optional) |
| **12S** | Vertebrates | Invertebrates, microbes, fungi, plants |
| **COI** | Metazoa | Plants, fungi, bacteria, archaea |

#### 📤 10. Export Files for R / Microeco

**Export ASV table:**

```bash
qiime tools export \
  --input-path table-no-contam.qza \
  --output-path 1_table-no-contam
```

Convert BIOM to TSV:

```bash
biom convert \
  -i 1_table-no-contam/feature-table.biom \
  -o 1_table-no-contam/feature-table.tsv \
  --to-tsv
```

**Export taxonomy:**

```bash
qiime tools export \
  --input-path taxonomy.qza \
  --output-path 2_taxonomy
```

**Export tree:**

```bash
qiime tools export \
  --input-path rooted-tree.qza \
  --output-path 3_tree
```

**Export sequences:**

```bash
qiime tools export \
  --input-path rep-seqs-no-contam.qza \
  --output-path 4_seqs
```

**Now we have:**

● feature-table.tsv

● taxonomy.tsv

● tree.nwk

● dna-sequences.fasta

**These feed directly into Microeco, phyloseq, vegan, etc.**

#### 🧰 Tomorrow (Day 3): Visualization & Statistics

Tomorrow we will cover:

● Alpha diversity

● Beta diversity

● PCoA/NMDS

● Taxonomy barplots

● Microeco visualizations

● Heatmaps, networks, Sankey diagrams

**Stay tuned — and check GitHub for marker-specific workflows.**

![qiime21](/assets/img/q2.png)
