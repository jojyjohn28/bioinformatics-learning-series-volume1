############################################################
# Simple stats for alpha and beta diversity
############################################################

library(tidyverse)
library(vegan)

# ==========================
# 1. Load data
# ==========================
# Replace with your paths
meta <- read.delim("my_metadata.txt", sep = "\t")
shannon <- read.delim("shannon/alpha-diversity.tsv", sep = "\t")
observed <- read.delim("observed_features/alpha-diversity.tsv", sep = "\t")
faith <- read.delim("faith_pd/alpha-diversity.tsv", sep = "\t")

colnames(shannon) <- c("SampleID", "Shannon")
colnames(observed) <- c("SampleID", "Observed")
colnames(faith) <- c("SampleID", "FaithPD")

# Merge
alpha_df <- meta %>%
  left_join(shannon, by = "SampleID") %>%
  left_join(observed, by = "SampleID") %>%
  left_join(faith, by = "SampleID")

alpha_df$Treatment <- factor(alpha_df$Treatment)

# ==========================
# 2. Alpha diversity stats
# ==========================

# ---- Kruskal-Wallis (global)
kw_shannon <- kruskal.test(Shannon ~ Treatment, data = alpha_df)
kw_observed <- kruskal.test(Observed ~ Treatment, data = alpha_df)
kw_faith <- kruskal.test(FaithPD ~ Treatment, data = alpha_df)

kw_shannon
kw_observed
kw_faith

# ---- Pairwise Wilcoxon
pw_shannon <- pairwise.wilcox.test(alpha_df$Shannon, alpha_df$Treatment, p.adjust.method = "BH")
pw_observed <- pairwise.wilcox.test(alpha_df$Observed, alpha_df$Treatment, p.adjust.method = "BH")
pw_faith <- pairwise.wilcox.test(alpha_df$FaithPD, alpha_df$Treatment, p.adjust.method = "BH")

pw_shannon
pw_observed
pw_faith

# ==========================
# 3. Beta diversity stats
# ==========================

# Load Bray-Curtis distance matrix
dist_mat <- read.delim("bray_distance/distance-matrix.tsv",
                       sep = "\t", row.names = 1)

dist_obj <- as.dist(dist_mat)

# ---- PERMANOVA
adon <- adonis2(dist_obj ~ Treatment, data = meta, permutations = 999)
adon

# Extract values
pval <- adon$`Pr(>F)`[1]
r2 <- adon$R2[1]

cat("PERMANOVA: R2 =", r2, "p =", pval, "\n")

# ==========================
# 4. Pairwise PERMANOVA
# ==========================

pairwise_adonis <- function(dist, factors) {
  comb <- combn(unique(factors), 2)
  results <- data.frame()
  
  for(i in 1:ncol(comb)){
    group <- comb[,i]
    idx <- factors %in% group
    
    sub_dist <- as.dist(as.matrix(dist)[idx, idx])
    sub_meta <- data.frame(Treatment = factors[idx])
    
    ad <- adonis2(sub_dist ~ Treatment, data = sub_meta)
    
    results <- rbind(results, data.frame(
      Group1 = group[1],
      Group2 = group[2],
      R2 = ad$R2[1],
      p = ad$`Pr(>F)`[1]
    ))
  }
  
  results$p_adj <- p.adjust(results$p, method = "BH")
  results
}

pairwise_results <- pairwise_adonis(dist_obj, meta$Treatment)
pairwise_results

# ==========================
# 5. Dispersion test (IMPORTANT)
# ==========================

disp <- betadisper(dist_obj, meta$Treatment)
anova_disp <- anova(disp)

anova_disp

# ==========================
# 6. Save summary tables
# ==========================

alpha_summary <- data.frame(
  Metric = c("Shannon", "Observed", "FaithPD"),
  p_value = c(kw_shannon$p.value, kw_observed$p.value, kw_faith$p.value)
)

write.csv(alpha_summary, "alpha_stats.csv", row.names = FALSE)
write.csv(pairwise_results, "pairwise_permanova.csv", row.names = FALSE)

############################################################