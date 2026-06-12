#### **QIIME2 Visualization & Diversity Analysis**

This document continues the workflow after denoising, contamination removal, and phylogenetic tree construction. Here, we generate rarefaction curves, alpha diversity, beta diversity, and taxonomy barplots — all core visualization outputs for amplicon analysis.

#### 📘 1. Generate Alpha Rarefaction Curves

Alpha rarefaction helps evaluate whether sequencing depth sufficiently captured microbial diversity within each sample.

```bash
qiime diversity alpha-rarefaction \
  --i-table table-no-contam.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 20000 \
  --m-metadata-file my_metadata.txt \
  --o-visualization alpha-rarefaction.qzv
```

📄 Output: alpha-rarefaction.qzv
🔍 View at: https://view.qiime2.org/

#### 📊 2. Core Diversity Metrics (Alpha + Beta Diversity)

This command runs the complete diversity pipeline, producing:

● Alpha diversity: Shannon, Evenness, Faith’s PD

● Beta diversity: Bray–Curtis, Jaccard, UniFrac (weighted & unweighted)

● Ordination: PCoA plots for each distance metric

● PERMANOVA files: for statistical testing

```bash
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table-no-contam.qza \
  --p-sampling-depth 20000 \
  --m-metadata-file my_metadata.txt \
  --output-dir core-metrics-results_20000
```

📂 Folder: core-metrics-results_20000/ contains:
| File | Description |
| ---------------------------------------- | ------------------------------ |
| `shannon_vector.qza` | Shannon diversity index |
| `evenness_vector.qza` | Pielou’s evenness |
| `faith_pd_vector.qza` | Faith’s phylogenetic diversity |
| `unweighted_unifrac_distance_matrix.qza` | Unweighted Unifrac |
| `weighted_unifrac_distance_matrix.qza` | Weighted Unifrac |
| `bray_curtis_distance_matrix.qza` | Bray–Curtis |
| `jaccard_distance_matrix.qza` | Jaccard distance |
| `…_pcoa_results.qza` | Ordination |
| `emperor.qzv` | Interactive PCoA visualization |

#### 🌈 3. Taxonomy Barplots

Taxonomy bar plots reveal taxonomic composition at different levels (phylum → genus).

```bash
qiime taxa barplot \
  --i-table table-no-contam.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file my_metadata.txt \
  --o-visualization taxa-bar-plots.qzv
```

📄 Output: taxa-bar-plots.qzv
🔍 Interactive viewing available online at QIIME2 viewer.

#### 📌 4. Optional but Recommended Analyses

These analyses provide statistical significance testing for your metadata categories (e.g., treatment, season, genotype)

**4.1 Alpha Diversity Significance (Group Comparisons)**

Example: Shannon index

```bash
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results_20000/shannon_vector.qza \
  --m-metadata-file my_metadata.txt \
  --o-visualization shannon-group-significance.qzv
```

Output includes:

    Boxplots of diversity by group

    Kruskal–Wallis p-values

    Pairwise comparisons

**4.2 Beta Diversity Significance (PERMANOVA)**

Example: Bray–Curtis

```bash
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results_20000/bray_curtis_distance_matrix.qza \
  --m-metadata-file my_metadata.txt \
  --m-metadata-column Treatment \
  --p-permutations 999 \
  --o-visualization bray-treatment-significance.qzv
```

This produces:

PERMANOVA table

PCoA ordination with group centroids

Pairwise tests

#### 🔄 Summary – Quick Command Block for Reference

# 1. Rarefaction curves

qiime diversity alpha-rarefaction \
 --i-table table-no-contam.qza \
 --i-phylogeny rooted-tree.qza \
 --p-max-depth 20000 \
 --m-metadata-file my_metadata.txt \
 --o-visualization alpha-rarefaction.qzv

# 2. Core metrics (alpha & beta diversity)

qiime diversity core-metrics-phylogenetic \
 --i-phylogeny rooted-tree.qza \
 --i-table table-no-contam.qza \
 --p-sampling-depth 20000 \
 --m-metadata-file my_metadata.txt \
 --output-dir core-metrics-results_20000

# 3. Taxonomy composition barplots

qiime taxa barplot \
 --i-table table-no-contam.qza \
 --i-taxonomy taxonomy.qza \
 --m-metadata-file my_metadata.txt \
 --o-visualization taxa-bar-plots.qzv
