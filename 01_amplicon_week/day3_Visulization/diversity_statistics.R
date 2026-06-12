###############################################################
# diversity_statistics.R  
# Alpha & Beta Diversity Statistical Analysis (Microeco + Phyloseq)
# Clean standalone script
###############################################################

library(microeco)
library(phyloseq)
library(vegan)
library(dplyr)

###############################################################
# 0. INPUT: Load your saved microeco object
# (Adjust if stored differently)
###############################################################

load("meco_physeq_ra.RData")  
# OR:
# meco_physeq_ra <- your_object_here

cat("Microeco object loaded:\n")
print(meco_physeq_ra)

###############################################################
# 1. ALPHA DIVERSITY STATISTICS
###############################################################

# Create alpha diversity object
t_alpha <- trans_alpha$new(dataset = meco_physeq_ra, group = "Treatment")

# Calculate diversity indices
t_alpha$cal_diff(method = "KW")      # Kruskal–Wallis
kw_res <- t_alpha$res_diff

t_alpha$cal_diff(method = "wilcox")  # Pairwise Wilcoxon
wilcox_res <- t_alpha$res_diff

t_alpha$cal_diff(method = "anova")   # ANOVA
anova_res <- t_alpha$res_diff

# Combine into a named list
alpha_results <- list(
  kruskal_wallis = kw_res,
  wilcoxon = wilcox_res,
  anova = anova_res
)

# Save
write.csv(kw_res,     "alpha_KruskalWallis_results.csv", row.names = FALSE)
write.csv(wilcox_res, "alpha_Wilcoxon_results.csv", row.names = FALSE)
write.csv(anova_res,  "alpha_ANOVA_results.csv", row.names = FALSE)

cat("\nAlpha diversity statistical tests saved!\n")

###############################################################
# 2. BETA DIVERSITY (BRAY–CURTIS) STATISTICS
###############################################################

# Calculate beta diversity matrices
meco_physeq_ra$cal_betadiv()

# Create Bray–Curtis trans_beta object
t_beta <- trans_beta$new(
  dataset = meco_physeq_ra,
  group   = "Treatment",
  measure = "bray"
)

###############################################################
# 2.1 PERMANOVA
###############################################################
t_beta$cal_manova(manova_all = TRUE)
permanova_res <- t_beta$res_manova

write.csv(permanova_res, "beta_PERMANOVA_BrayCurtis.csv", row.names = FALSE)

cat("\nPERMANOVA results saved!\n")

###############################################################
# 2.2 Test Homogeneity of Group Dispersions (Betadisper)
###############################################################

t_beta$cal_betadisper()
betadisper_res <- t_beta$res_betadisper

write.csv(betadisper_res, "beta_Betadisper_BrayCurtis.csv", row.names = FALSE)

cat("\nBetadisper (variance homogeneity) results saved!\n")

###############################################################
# 3. EXPORT COMBINED LIST FOR PROGRAMMATIC USE
###############################################################

div_stats <- list(
  alpha = alpha_results,
  permanova = permanova_res,
  betadisper = betadisper_res
)

save(div_stats, file = "diversity_statistics.RData")

cat("\nAll diversity statistics saved to diversity_statistics.RData\n")
cat("Script complete.\n")
