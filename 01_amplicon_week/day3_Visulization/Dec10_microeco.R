###############################################################
# Bacillus 16S amplicon – Full R Workflow
# Author: Jojy — community analysis, LEfSe, FAPROTAX, microeco
###############################################################

############################
# 0. LOAD LIBRARIES
############################
library(phyloseq)
library(ggplot2)
library(vegan)
library(dplyr)
library(tidyr)
library(stringr)
library(pheatmap)
library(microeco)
library(file2meco)
library(paletteer)
library(forcats)
library(tibble)

###############################################################
# 1. IMPORT DATA & BUILD PHYLOSEQ + MICROECO OBJECTS
###############################################################

setwd("~/Jojy_Research_Sync/Collaborative_works/bacillus/qiime2")

otu_table_p <- read.table("qiime/1_table-no-contam/feature-table.tsv",
                          header = TRUE, row.names = 1, sep = "\t", check.names = FALSE)

taxonomy_p  <- read.table("qiime/2_taxonomy/taxonomy.tsv",
                          header = TRUE, row.names = 1, sep = "\t", check.names = FALSE)

metadata_p  <- read.table("qiime/my_metadata.txt",
                          header = TRUE, row.names = 2, sep = "\t", check.names = FALSE)

# Convert to matrices
otu_table_matrix <- as.matrix(otu_table_p)
taxonomy_matrix  <- as.matrix(taxonomy_p)

# Build phyloseq object
Ata_otu        <- otu_table(otu_table_matrix, taxa_are_rows = TRUE)
Ata_tax        <- tax_table(taxonomy_matrix)
Ata_tree       <- read_tree("3_tree/tree.nwk")
Ata_sampledata <- sample_data(metadata_p)

# Fix sample names
sample_names(Ata_sampledata) <- gsub("^/", "", sample_names(Ata_sampledata))
sample_names(Ata_sampledata) <- sub("-.*", "", sample_names(Ata_sampledata))

physeq <- phyloseq(Ata_otu, Ata_tax, Ata_sampledata, Ata_tree)
physeq

# Filter only prokaryotes & remove low-abundance ASVs
physeq_Prokaryotes <- subset_taxa(physeq, Kingdom == "Bacteria" | Kingdom == "Archaea")
physeq_cutoff      <- filter_taxa(physeq_Prokaryotes, function(x) sum(x) > 10, TRUE)

# Rarefy
min_depth <- min(sample_sums(physeq_cutoff))
physeq_ra <- rarefy_even_depth(physeq_cutoff, sample.size = min_depth, replace = FALSE)

# Convert to microeco
meco_physeq_ra <- phyloseq2meco(physeq_ra)
meco_physeq_ra$tidy_dataset()

# Fix factors
meco_physeq_ra$sample_table$Treatment <- factor(
  meco_physeq_ra$sample_table$Treatment,
  levels = c("NC", "NPK", "nOB9")
)

###############################################################
# 2. COMMUNITY COMPOSITION — BAR PLOTS
###############################################################

# Palette generator
taxa_palette <- function(n) {
  base_cols <- as.character(paletteer_d("ggthemes::Classic_20"))
  grDevices::colorRampPalette(base_cols)(n)
}

# Phylum-level
t_phylum <- trans_abund$new(dataset = meco_physeq_ra, taxrank = "Phylum", ntaxa = 20)
p_phylum <- t_phylum$plot_bar(
  others_color = "grey70",
  legend_text_italic = FALSE,
  color_values = taxa_palette(20)
)
p_phylum

# Family-level
t_family <- trans_abund$new(dataset = meco_physeq_ra, taxrank = "Family", ntaxa = 20)
p_family <- t_family$plot_bar(
  others_color = "grey70",
  legend_text_italic = FALSE,
  color_values = taxa_palette(20)
)
p_family

# Genus-level
t_genus <- trans_abund$new(dataset = meco_physeq_ra, taxrank = "Genus", ntaxa = 20)
p_genus <- t_genus$plot_bar(
  others_color = "grey70",
  legend_text_italic = FALSE,
  color_values = taxa_palette(20)
)
p_genus

###############################################################
# 3. HEATMAPS — Z-SCORE NORMALIZED ACROSS TAXA
###############################################################

heatmap_from_trans_abund <- function(trans_obj, title = "") {
  
  df <- trans_obj$data_abund
  
  mat_df <- df %>%
    select(Taxonomy, Sample, Abundance) %>%
    pivot_wider(names_from = Sample, values_from = Abundance)
  
  taxa_names <- mat_df$Taxonomy
  
  mat <- mat_df %>%
    select(-Taxonomy) %>%
    as.matrix() %>%
    apply(2, as.numeric)
  
  rownames(mat) <- taxa_names
  
  # z-score across rows
  mat_z <- t(scale(t(mat)))
  mat_z[is.na(mat_z)] <- 0
  
  pheatmap(
    mat_z,
    fontsize_row = 6,
    fontsize_col = 10,
    main = title
  )
}

heatmap_from_trans_abund(t_phylum, "Top 20 Phyla (z-score)")
heatmap_from_trans_abund(t_family, "Top 20 Families (z-score)")
heatmap_from_trans_abund(t_genus, "Top 20 Genera (z-score)")

###############################################################
# 4. ALPHA DIVERSITY — SHANNON INDEX
###############################################################

t_alpha <- trans_alpha$new(dataset = meco_physeq_ra, group = "Treatment")

# Run significance tests
t_alpha$cal_diff(method = "KW")
t_alpha$cal_diff(method = "wilcox")
t_alpha$cal_diff(method = "anova")

p_alpha <- t_alpha$plot_alpha(measure = "Shannon") +
  theme_classic()
p_alpha

###############################################################
# 5. BETA DIVERSITY — BRAY PCoA + PERMANOVA
###############################################################

meco_physeq_ra$cal_betadiv()

t_beta <- trans_beta$new(dataset = meco_physeq_ra,
                         group = "Treatment",
                         measure = "bray")

t_beta$cal_ordination(method = "PCoA")

p_beta <- t_beta$plot_ordination(
  plot_color = "Treatment",
  plot_shape = "Treatment",
  plot_type  = c("point", "ellipse")
)
p_beta

t_beta$cal_manova(manova_all = TRUE)

###############################################################
# 6. LEfSe — TOP GENUS-LEVEL FEATURES
###############################################################

t_lefse <- trans_diff$new(
  dataset = meco_physeq_ra,
  method = "lefse",
  group = "Treatment",
  taxa_level = "Genus"
)

lefse_df <- t_lefse$res_diff %>%
  select(Taxa, Group, LDA) %>%
  mutate(
    LDA = as.numeric(LDA),
    Genus = str_extract(Taxa, "g__[^|]+") %>%
      str_replace("g__", "") %>%
      str_replace("_", " ")
  )

lefse_top <- lefse_df %>%
  arrange(desc(abs(LDA))) %>%
  slice(1:30) %>%
  mutate(Genus = factor(Genus, levels = rev(unique(Genus))))

treat_cols <- c("NC" = "#E41A1C", "NPK" = "#377EB8", "nOB9" = "#4DAF4A")

p_lefse <- ggplot(lefse_top, aes(x = Genus, y = LDA, fill = Group)) +
  geom_col(color = "black") +
  coord_flip() +
  scale_fill_manual(values = treat_cols) +
  theme_bw() +
  labs(title = "Top LEfSe-Enriched Genera", y = "LDA Score (log10)", x = "")
p_lefse

###############################################################
# 7. FAPROTAX FUNCTIONAL ANNOTATION
###############################################################

t_func <- trans_func$new(meco_physeq_ra)
t_func$for_what <- "prok"

t_func$cal_spe_func(prok_database = "FAPROTAX")
t_func$cal_func()
t_func$cal_func_FR()
t_func$cal_spe_func_perc()

func_perc <- t_func$res_spe_func_perc %>%
  as.data.frame() %>%
  rownames_to_column("SampleName")

meta_df <- meco_physeq_ra$sample_table %>%
  as.data.frame() %>%
  rownames_to_column("SampleName")

func_long <- func_perc %>%
  left_join(meta_df, by = "SampleName") %>%
  pivot_longer(
    cols = where(is.numeric),
    names_to = "Function",
    values_to = "Perc"
  )

# Top 20 functions
top20 <- func_long %>%
  group_by(Function) %>%
  summarise(meanPerc = mean(Perc)) %>%
  slice_max(meanPerc, n = 20)

func_top <- func_long %>% semi_join(top20, "Function")

# Barplot
p_faprotax <- ggplot(func_top, aes(x = Treatment, y = Perc, fill = Function)) +
  geom_col(color = "black") +
  scale_fill_manual(values = taxa_palette(20)) +
  theme_bw() +
  labs(title = "Top FAPROTAX Functions", y = "Mean % Contribution")
p_faprotax

###############################################################
# 8. VENN DIAGRAM OF SHARED ASVs
###############################################################

venn_data <- meco_physeq_ra$merge_samples("Treatment")
t_venn <- trans_venn$new(dataset = venn_data, ratio = "seqratio")
p_venn <- t_venn$plot_venn()
p_venn

###############################################################
# END OF SCRIPT
###############################################################
