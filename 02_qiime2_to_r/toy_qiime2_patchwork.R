############################################################
# Toy QIIME2-style visualization (publication format)
############################################################

library(tidyverse)
library(vegan)
library(patchwork)
library(viridis)
library(cowplot)

set.seed(42)

# ==========================
# 1. Metadata
# ==========================
meta <- data.frame(
  SampleID = paste0("S", 1:12),
  Treatment = rep(c("Control", "Test1", "Test2", "Test3"), each = 3)
)

meta$Treatment <- factor(meta$Treatment, levels = c("Control", "Test1", "Test2", "Test3"))

# ==========================
# 2. Alpha diversity (toy)
# ==========================
# ==========================
# 2. Alpha diversity (toy)
# ==========================
alpha_df <- meta %>%
  mutate(
    Shannon  = c(rnorm(3, 5.2, 0.15), rnorm(3, 5.6, 0.18), rnorm(3, 5.9, 0.16), rnorm(3, 5.4, 0.17)),
    Observed = c(rnorm(3, 180, 12),   rnorm(3, 155, 15),   rnorm(3, 210, 14),   rnorm(3, 190, 13)),
    FaithPD  = c(rnorm(3, 15.5, 1.0), rnorm(3, 13.0, 1.1), rnorm(3, 16.8, 0.9), rnorm(3, 14.2, 1.0))
  )

alpha_long <- alpha_df %>%
  pivot_longer(
    cols = c(Shannon, Observed, FaithPD),
    names_to = "Metric",
    values_to = "Value"
  )

p_alpha <- ggplot(alpha_long, aes(Treatment, Value, fill = Treatment)) +
  geom_boxplot(alpha = 0.5, outlier.shape = NA) +
  geom_jitter(width = 0.08, size = 2) +
  facet_wrap(~Metric, scales = "free_y") +
  scale_fill_viridis_d() +
  theme_bw() +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold"),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)
  )
# ==========================
# 3. Beta diversity (toy, improved)
# ==========================
ord_df <- data.frame(
  SampleID = meta$SampleID,
  Treatment = meta$Treatment,
  PC1 = c(-0.22, -0.18, -0.20,
          -0.05, -0.02, -0.06,
          0.12,  0.16,  0.14,
          0.30,  0.27,  0.33),
  PC2 = c( 0.05,  0.09,  0.07,
           -0.06, -0.02, -0.08,
           0.10,  0.14,  0.11,
           -0.04, -0.01, -0.06)
)

p_beta <- ggplot(ord_df, aes(PC1, PC2, color = Treatment)) +
  geom_point(size = 3) +
  stat_ellipse(linewidth = 0.8, show.legend = FALSE) +
  scale_color_viridis_d() +
  theme_bw() +
  theme(legend.position = "right")
# ==========================
# 4. Phylum abundance (toy)
# ==========================
phyla <- c("Proteobacteria", "Actinobacteria", "Firmicutes", "Bacteroidetes")

abundance <- expand.grid(
  SampleID = meta$SampleID,
  Phylum = phyla
)

abundance$Abundance <- runif(nrow(abundance))
abundance <- abundance %>%
  group_by(SampleID) %>%
  mutate(Abundance = Abundance / sum(Abundance)) %>%
  ungroup()

abundance <- left_join(abundance, meta, by = "SampleID")

p_phylum <- ggplot(abundance, aes(SampleID, Abundance, fill = Phylum)) +
  geom_col(color = "white", linewidth = 0.2) +
  facet_grid(. ~ Treatment, scales = "free_x", space = "free_x") +
  scale_fill_viridis_d() +
  scale_y_continuous(labels = scales::percent) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 90),
    strip.text = element_text(face = "bold")
  )

# ==========================
# 5. Add panel labels
# ==========================
p_alpha_l <- ggdraw(p_alpha) + draw_label("a", x = 0.02, y = 0.98, hjust = 0, vjust = 1, fontface = "bold")
p_beta_l  <- ggdraw(p_beta)  + draw_label("b", x = 0.02, y = 0.98, hjust = 0, vjust = 1, fontface = "bold")
p_phylum_l<- ggdraw(p_phylum)+ draw_label("c", x = 0.02, y = 0.98, hjust = 0, vjust = 1, fontface = "bold")

# ==========================
# 6. Patchwork layout
# ==========================
final_plot <- (p_alpha_l | p_beta_l) /
  (p_phylum_l)

final_plot

# ==========================
# 7. Save
# ==========================
ggsave("toy_patchwork_publication.png", final_plot, width = 14, height = 10, dpi = 300)
ggsave("toy_patchwork_publication.pdf", final_plot, width = 14, height = 10)

# show
final_plot