############################################################
# Tax4Fun2 Visualization Script
# Heatmap of Top Pathways + Redundancy Plot
############################################################

library(tidyverse)
library(pheatmap)

# Load Tax4Fun2 pathway table
path <- t4f$res_tax4fun2_pathway

# Select top 20 pathways by mean abundance
top20_path <- path %>%
  mutate(Pathway = rownames(.)) %>%
  pivot_longer(-Pathway, names_to="Sample", values_to="Abundance") %>%
  group_by(Pathway) %>%
  summarise(meanA = mean(Abundance)) %>%
  top_n(20, meanA) %>%
  pull(Pathway)

mat <- path[top20_path, ]
rownames(mat) <- top20_path

# Heatmap
pheatmap(mat,
         fontsize_row=7,
         clustering_method="complete",
         main="Top 20 KEGG Pathways (Tax4Fun2)")

# Plot functional redundancy
redundancy <- data.frame(
  Sample = names(t4f$res_tax4fun2_rFRI),
  rFRI = t4f$res_tax4fun2_rFRI
)

ggplot(redundancy, aes(x=Sample, y=rFRI)) +
  geom_col(fill="#1f78b4") +
  theme_bw() +
  labs(title="Relative Functional Redundancy (Tax4Fun2)",
       y="rFRI Score")
