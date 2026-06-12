#### 🧪 Amplicon Week 2025 – Day 3: Visualization & Statistics

**Welcome to Day 3 of the Amplicon Sequencing Series!**
Today’s focus is on visualization and downstream statistical analysis using QIIME2 outputs and R-based tools (microeco + phyloseq).

This folder contains all scripts and resources needed to reproduce the figures, diversity metrics, and ecological insights presented in Day 3.

📁 Folder Contents
1️⃣ Dec10_microeco.R

A complete R workflow for generating publication-ready microbial ecology visualizations using microeco:

● Taxonomic barplots (Phylum, Family, Genus)

● Heatmaps (z-score normalized)

● Venn diagrams

● Alpha diversity plots

● Beta diversity (PCoA with ellipses)

● LEfSe genus-level LDA plots

● Functional inference (FAPROTAX)

● Export of all intermediate tables

This script uses a phyloseq → microeco workflow built from QIIME2 outputs.

2️⃣ diversity_statistics.R

A clean standalone script that performs all statistical tests for diversity analyses:

**Alpha Diversity Statistics**

● Kruskal–Wallis

● Pairwise Wilcoxon

● ANOVA

**Beta Diversity Statistics**

● Bray–Curtis PERMANOVA
Outputs are saved as CSV files plus a combined .RData object.

3️⃣ qiime2_visualization.md

A step-by-step guide explaining how to visualize QIIME2 results:

● Rarefaction curves

● Core-metrics-phylogenetic output

● Alpha/beta diversity interpretation

● Taxonomy barplots

● Exporting QZA/QZV for R analysis

Perfect for beginners transitioning from QIIME2 to R.

4️⃣ files/

A folder containing the base input files used in R:

● feature-table.tsv

● taxonomy.tsv

● metadata.txt

● tree.nwk

Use these if you want to run the scripts exactly as demonstrated.

🚀 How to Get Started

Activate your R environment with microeco + phyloseq installed.

Run Dec10_microeco.R for full visualization.

Run diversity_statistics.R to generate alpha/beta diversity statistics.

Refer to qiime2_visualization.md if you want to compare R outputs with QIIME2 visualizations.

#### 💬 Support

If you're following the Amplicon Week 2025 series, feel free to open issues on GitHub or tag me on LinkedIn with your questions and visualizations!

Happy analyzing! 🎉🔬
