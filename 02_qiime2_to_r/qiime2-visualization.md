# QIIME 2 data export, BIOM-to-TSV conversion, and R visualization

This guide shows a simple workflow to:

1. export QIIME 2 artifacts for downstream analysis,
2. convert BIOM tables to TSV format,
3. prepare files for R,
4. build publication-style figures in R.

The examples below assume you already completed a QIIME 2 workflow and have outputs such as:

- `table-no-contam.qza` or `table-no-contam_240_200.qza`
- `taxonomy.qza`
- `denoising-stats.qza`
- `core-metrics-results/`
- `rooted-tree.qza`

You can adapt file names to match your own project.

---

## 1. Create a clean export directory

It is best to keep all exported files in a separate folder.

```bash
mkdir -p qiime2_R_export
```

---

## 2. Export key QIIME 2 artifacts

### Export denoising stats

```bash
qiime tools export \
  --input-path denoising-stats_240_200.qza \
  --output-path qiime2_R_export/denoising_stats
```

### Export filtered ASV table

```bash
qiime tools export \
  --input-path table-no-contam_240_200.qza \
  --output-path qiime2_R_export/table
```

### Export taxonomy

```bash
qiime tools export \
  --input-path taxonomy_240_200.qza \
  --output-path qiime2_R_export/taxonomy
```

### Export alpha diversity vectors

```bash
qiime tools export \
  --input-path core-metrics-results_50000/shannon_vector.qza \
  --output-path qiime2_R_export/shannon

qiime tools export \
  --input-path core-metrics-results_50000/observed_features_vector.qza \
  --output-path qiime2_R_export/observed_features

qiime tools export \
  --input-path core-metrics-results_50000/faith_pd_vector.qza \
  --output-path qiime2_R_export/faith_pd
```

### Export beta diversity outputs

```bash
qiime tools export \
  --input-path core-metrics-results_50000/bray_curtis_distance_matrix.qza \
  --output-path qiime2_R_export/bray_distance

qiime tools export \
  --input-path core-metrics-results_50000/bray_curtis_pcoa_results.qza \
  --output-path qiime2_R_export/bray_pcoa
```

---

## 3. Collapse taxonomy to phylum / family / genus

For stacked abundance plots, collapse the feature table at the required taxonomic level.

### Phylum

```bash
qiime taxa collapse \
  --i-table table-no-contam_240_200.qza \
  --i-taxonomy taxonomy_240_200.qza \
  --p-level 2 \
  --o-collapsed-table phylum.qza
```

### Family

```bash
qiime taxa collapse \
  --i-table table-no-contam_240_200.qza \
  --i-taxonomy taxonomy_240_200.qza \
  --p-level 5 \
  --o-collapsed-table family.qza
```

### Genus

```bash
qiime taxa collapse \
  --i-table table-no-contam_240_200.qza \
  --i-taxonomy taxonomy_240_200.qza \
  --p-level 6 \
  --o-collapsed-table genus.qza
```

---

## 4. Convert collapsed tables to relative abundance

```bash
qiime feature-table relative-frequency \
  --i-table phylum.qza \
  --o-relative-frequency-table phylum_rel.qza

qiime feature-table relative-frequency \
  --i-table family.qza \
  --o-relative-frequency-table family_rel.qza

qiime feature-table relative-frequency \
  --i-table genus.qza \
  --o-relative-frequency-table genus_rel.qza
```

---

## 5. Export the relative abundance tables

```bash
qiime tools export --input-path phylum_rel.qza --output-path qiime2_R_export/phylum
qiime tools export --input-path family_rel.qza --output-path qiime2_R_export/family
qiime tools export --input-path genus_rel.qza  --output-path qiime2_R_export/genus
```

---

## 6. Convert BIOM files to TSV

QIIME 2 exports feature tables as BIOM. Many R workflows are easier with TSV files.

Run these from inside your export directory:

```bash
cd qiime2_R_export

biom convert -i table/feature-table.biom  -o table/feature-table.tsv  --to-tsv
biom convert -i phylum/feature-table.biom -o phylum/feature-table.tsv --to-tsv
biom convert -i family/feature-table.biom -o family/feature-table.tsv --to-tsv
biom convert -i genus/feature-table.biom  -o genus/feature-table.tsv  --to-tsv
```

If `biom` is not available in your current shell, activate your QIIME 2 environment first.

---

## 7. Copy metadata into the export folder

```bash
cp my_metadata.txt qiime2_R_export/
```

At this point, your export folder may look like this:

```text
qiime2_R_export/
├── bray_distance/
├── bray_pcoa/
├── denoising_stats/
├── faith_pd/
├── observed_features/
├── shannon/
├── table/
│   ├── feature-table.biom
│   └── feature-table.tsv
├── taxonomy/
│   └── taxonomy.tsv
├── phylum/
│   ├── feature-table.biom
│   └── feature-table.tsv
├── family/
│   ├── feature-table.biom
│   └── feature-table.tsv
├── genus/
│   ├── feature-table.biom
│   └── feature-table.tsv
└── my_metadata.txt
```

---

## 8. View QIIME 2 visualization files

If you also generated `.qzv` files such as taxonomic barplots or Emperor plots, you can view them in two ways.

### Local viewing

```bash
qiime tools view taxa-bar-plots_240_200.qzv
```

### Web viewer

Upload the `.qzv` file to:

- `https://view.qiime2.org`

This is useful for sharing interactive plots with collaborators.

---

## 9. Read exported TSV files in R

A small helper function makes this easier.

```r
read_qiime_tsv <- function(path) {
  x <- read.delim(
    path,
    sep = "\t",
    header = TRUE,
    comment.char = "",
    check.names = FALSE,
    stringsAsFactors = FALSE,
    skip = 1
  )
  colnames(x)[1] <- "Taxon"
  x
}
```

The `skip = 1` part is important because TSV files converted from BIOM often begin with a comment line such as `# Constructed from biom file`.

---

## 10. Example: alpha diversity plotting in R

```r
library(tidyverse)

meta <- read.delim("my_metadata.txt", sep = "\t", check.names = FALSE)
colnames(meta)[1] <- "SampleID"

shannon <- read.delim("shannon/alpha-diversity.tsv", sep = "\t")
colnames(shannon) <- c("SampleID", "Shannon")

observed <- read.delim("observed_features/alpha-diversity.tsv", sep = "\t")
colnames(observed) <- c("SampleID", "Observed")

faith <- read.delim("faith_pd/alpha-diversity.tsv", sep = "\t")
colnames(faith) <- c("SampleID", "FaithPD")

alpha_df <- meta %>%
  left_join(shannon, by = "SampleID") %>%
  left_join(observed, by = "SampleID") %>%
  left_join(faith, by = "SampleID")

alpha_long <- alpha_df %>%
  pivot_longer(
    cols = c(Shannon, Observed, FaithPD),
    names_to = "Metric",
    values_to = "Value"
  )

ggplot(alpha_long, aes(x = Treatment, y = Value, fill = Treatment)) +
  geom_boxplot(alpha = 0.5, outlier.shape = NA) +
  geom_jitter(width = 0.1, size = 2) +
  facet_wrap(~ Metric, scales = "free_y") +
  theme_bw()
```

---

## 11. Example: phylum-level stacked barplot in R

```r
library(tidyverse)
library(viridis)

extract_phylum <- function(taxon_string) {
  sapply(taxon_string, function(x) {
    parts <- trimws(unlist(strsplit(x, ";")))
    if (length(parts) < 2) return("Unassigned")
    val <- sub("^[a-z]__", "", parts[2])
    if (val == "" || is.na(val)) "Unassigned" else val
  })
}

phylum_tab <- read_qiime_tsv("phylum/feature-table.tsv")

phylum_long <- phylum_tab %>%
  pivot_longer(-Taxon, names_to = "SampleID", values_to = "Abundance") %>%
  mutate(
    Abundance = as.numeric(Abundance),
    Phylum = extract_phylum(Taxon)
  ) %>%
  group_by(SampleID, Phylum) %>%
  summarise(Abundance = sum(Abundance, na.rm = TRUE), .groups = "drop") %>%
  left_join(meta, by = "SampleID")

# keep only top phyla and merge the rest as Other
keep <- phylum_long %>%
  group_by(Phylum) %>%
  summarise(Total = sum(Abundance), .groups = "drop") %>%
  arrange(desc(Total)) %>%
  slice_head(n = 12) %>%
  pull(Phylum)

plot_df <- phylum_long %>%
  mutate(Phylum = ifelse(Phylum %in% keep, Phylum, "Other")) %>%
  group_by(SampleID, Treatment, Phylum) %>%
  summarise(Abundance = sum(Abundance), .groups = "drop")

ggplot(plot_df, aes(x = SampleID, y = Abundance, fill = Phylum)) +
  geom_col(width = 0.9, colour = "white", linewidth = 0.1) +
  scale_fill_viridis_d(option = "turbo") +
  facet_grid(. ~ Treatment, scales = "free_x", space = "free_x") +
  scale_y_continuous(labels = function(x) paste0(round(x * 100), "%")) +
  theme_bw()
```

---

## 12. Recommended files to share with collaborators

At minimum, share:

- `taxonomy.tsv`
- `phylum_long.csv`
- `family_long.csv`
- `genus_long.csv`
- `alpha_diversity.csv`
- key figures as `.png` or `.svg`
- `.qzv` files for interactive inspection

Optional but useful:

- rhizobia- or Rhizobiales-focused summary tables
- Bray-Curtis distance matrix
- PCoA coordinates

---

## 13. Notes and good practices

- Keep file names consistent across all steps.
- Do not overwrite output folders; QIIME 2 will stop if the folder already exists.
- Use relative abundance tables for stacked barplots.
- For rhizobia or Rhizobiales-focused panels, make it clear whether the plot shows:
  - genus-level taxa only, or
  - higher taxonomic aggregation such as family/order-level groups.
- If you create zoomed taxon-only panels, note that excluding `Other` means the bars do not represent the full community.

---

## 14. Next step

Once files are exported and converted, you can use a standalone R script to generate:

- alpha diversity plots,
- beta diversity PCoA,
- phylum/family/genus abundance plots,
- patchwork-style multi-panel figures for papers, slides, blog posts, or LinkedIn.
