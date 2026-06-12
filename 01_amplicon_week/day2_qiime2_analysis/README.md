### 📘 Day 2 — QIIME2 Workflow: Import → DADA2 → Taxonomy → Tree → Export

This folder contains the core workflows for processing paired-end amplicon sequencing data using QIIME2, covering:

● 16S (bacteria/archaea)

● ITS (fungi)

● 18S (eukaryotes)

● 12S (vertebrate eDNA)

● COI (metazoan barcoding)

**The steps demonstrated here follow a typical metabarcoding pipeline:**

1. Import raw FASTQ data

2. Primer removal (cutadapt)

3. Denoising with DADA2

4. Taxonomic classification

5. Contamination filtering (marker-specific)

6. Phylogenetic tree construction

7. Export of key output files for R/Microeco/phyloseq

Each marker gene has its own workflow file:

16S_workflow.md
ITS_workflow.md
18S_workflow.md
12S_workflow.md
COI_workflow.md

#### 🔬 What This Day Covers

**✔ Importing Data**

Using manifest files or CASAVA-formatted directories.

**✔ Primer Removal**

Using cutadapt with gene-specific primer sequences.

**✔ DADA2 Denoising**

Filtering, merging, chimera removal, ASV generation.

**✔ Choosing the Correct Classifier**

Guidelines for:

Marker Recommended Database
16S SILVA 138.1, GTDB
ITS UNITE
18S PR2 / SILVA 132
12S MitoFish
COI MIDORI, BOLD

**✔ Taxonomic Assignment**

Using classify-sklearn with pre-trained or custom classifiers.

**✔ Contamination Removal**

Marker-specific filtering examples:

● 16S → remove mitochondria & chloroplasts

● ITS → keep only Fungi

● 18S → keep Eukaryota, remove Bacteria/Archaea

● 12S → keep Vertebrata

● COI → keep Animalia

**✔ Phylogenetic Tree**

Using align-to-tree-mafft-fasttree.

**✔ Exporting Files**

● Export R-ready outputs:

● feature-table.tsv

● taxonomy.tsv

● tree.nwk

● dna-sequences.fasta

#### 📚 Next Steps

**📅 Day 3 — Visualization & Microeco**

● Rarefaction

● Alpha & beta diversity

● Ordination (PCoA/NMDS)

● Taxonomy plots

● Importing QIIME2 outputs into Microeco (R)
