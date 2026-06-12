############################################################
# FAPROTAX Visualization Script
# Top Ecological Functions
############################################################

library(tidyverse)
library(pheatmap)

func <- t_func$res_spe_func_perc

# Select top functions
top_fun <- func %>%
  mutate(Function = rownames(.)) %>%
  pivot_longer(-Function, names_to="Sample", values_to="Perc") %>%
  group_by(Function) %>%
  summarise(meanP = mean(Perc)) %>%
  top_n(20, meanP) %>%
  pull(Function)

mat <- func[top_fun, ]
rownames(mat) <- top_fun

pheatmap(mat,
         fontsize_row=7,
         clustering_method="complete",
         main="Top 20 Ecological Functions (FAPROTAX)")

