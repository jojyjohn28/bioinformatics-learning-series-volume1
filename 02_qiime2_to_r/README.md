## QIIME2 outputs → R visualization

A simple workflow to go from **QIIME2 outputs → R visualization → basic statistics** for amplicon data.

This repository is part of a learning series focused on generating **publication-quality figures** and **basic ecological statistics** from QIIME2 results using R.

---

## 📂 Repository structure

qiime2-visualization.md
Simple_stats_for_alpha_beta_diversity.R
toy_qiime2_patchwork.R
README.md


---

## 📘 Files overview

### `qiime2-visualization.md`
Step-by-step guide to:
- Export QIIME2 artifacts (`.qza`)
- Convert BIOM to TSV
- Prepare data for R
- Build figures from scratch

---

### `Simple_stats_for_alpha_beta_diversity.R`
Basic statistical analysis including:
- Alpha diversity:
  - Kruskal–Wallis test
  - Pairwise Wilcoxon test
- Beta diversity:
  - PERMANOVA (adonis2)
  - Pairwise PERMANOVA
  - Dispersion test (betadisper)

---

### `toy_qiime2_patchwork.R`
Generates a **publication-style multi-panel figure** using toy data:
- (a) Alpha diversity (Shannon, Observed, Faith PD)
- (b) Beta diversity (PCoA)
- (c) Phylum-level abundance

Output:
- `toy_patchwork_publication.png`
- `toy_patchwork_publication.pdf`

---

## 🚀 Workflow summary

1. Run analysis in QIIME2  
2. Export results (`.qza → .tsv / .biom`)  
3. Import into R  
4. Generate:
   - Alpha diversity plots  
   - Beta diversity (PCoA)  
   - Taxonomic composition  
5. Perform simple statistical tests  

---

## 🧪 Requirements

### QIIME2
- For exporting data

### R packages
```r
tidyverse
vegan
patchwork
ggplot2
viridis
cowplot

🎯 Purpose

This repo avoids heavy wrappers (e.g., microeco) and instead uses:

● direct data handling
● simple R plotting
● transparent statistical testing

💡 Notes
● Designed for beginners transitioning from QIIME2 to R
● Fully customizable workflow
● Easy to adapt to real datasets

📬 Contact

Feel free to reach out if you have questions or suggestions!


---

If you want, I can also:
- add a **LinkedIn-ready banner image**
- or structure this repo like your **“Day 1 / Day 2” series style**
# qiime2-R
