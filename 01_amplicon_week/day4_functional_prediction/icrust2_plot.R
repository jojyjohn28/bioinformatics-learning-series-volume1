############################################################
# PICRUSt2 Visualization Script
# Plot Top 20 KO Functions
############################################################

library(tidyverse)

# Load KO table
ko <- read.table("picrust2_out/KO_metagenome_out/pred_metagenome_unstrat.tsv",
                 sep="\t", header=TRUE, row.names=1, check.names=FALSE)

# Identify top 20 KOs
ko_top20 <- ko %>%
  mutate(KO = rownames(.)) %>%
  pivot_longer(-KO, names_to="Sample", values_to="Abundance") %>%
  group_by(KO) %>%
  summarise(meanA = mean(Abundance)) %>%
  top_n(20, meanA) %>%
  pull(KO)

# Prepare long format table
ko_long <- ko[ko_top20, ] %>%
  mutate(KO = rownames(.)) %>%
  pivot_longer(-KO, names_to="Sample", values_to="Abundance")

# Plot
ggplot(ko_long, aes(x=reorder(KO, Abundance), y=Abundance, fill=Sample)) +
  geom_col(position="dodge") +
  coord_flip() +
  theme_bw(base_size=13) +
  labs(title="Top 20 KO Functions (PICRUSt2)",
       x="KEGG Ortholog", y="Predicted Abundance") +
  theme(legend.position="right")
