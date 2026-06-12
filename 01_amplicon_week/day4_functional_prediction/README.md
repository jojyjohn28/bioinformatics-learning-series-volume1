# 🌿 Amplicon Week – Day 4

## Functional Prediction: PICRUSt2 • Tax4Fun2 • FAPROTAX

This folder contains all files needed to perform functional prediction from amplicon sequencing data.

---

# 📁 Contents

| File                      | Description                                                      |
| ------------------------- | ---------------------------------------------------------------- |
| `installation_and_run.md` | Installation + run instructions for PICRUSt2, Tax4Fun2, FAPROTAX |
| `picrust2_plot.R`         | ggplot visualization of KO/pathway output                        |
| `tax4fun_plot.R`          | KEGG pathway heatmap                                             |
| `faprotax_plot.R`         | Ecological function heatmaps                                     |

---

# 🔧 Tools Included

### ✔ PICRUSt2

Predicts KEGG orthologs, EC numbers, metabolic pathways.

### ✔ Tax4Fun2

Uses SILVA to estimate KEGG pathways + functional redundancy.

### ✔ FAPROTAX

Assigns ecological roles (nitrification, methanogenesis, sulfate reduction, etc.).

---

# 🎨 Visualization Scripts

All R scripts use:

- **tidyverse**
- **pheatmap**
- **ggplot2**
- **microeco (for Tax4Fun2 & FAPROTAX)**

You can directly adapt them for your 16S / ITS / 18S / 12S / COI amplicon datasets.

---

# 📬 Questions?

Feel free to message me if you want help adapting these workflows to your data.

Happy analyzing! 🚀
