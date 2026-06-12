### 📦 Day 4 – Functional Prediction from Amplicon Data

#### Installation & Running PICRUSt2, Tax4Fun2, and FAPROTAX

This guide explains how to install and run all three functional prediction tools used in Day 4 of the Amplicon Week series.

---

#### 1️⃣ Required Input Files

Export from QIIME2:

```bash
qiime tools export --input-path table-no-contam.qza --output-path export_table
qiime tools export --input-path taxonomy.qza --output-path export_taxonomy
qiime tools export --input-path rep-seqs.qza --output-path export_seqs
```

Please find demo files in day 3.
You will need:

●feature-table.tsv

●taxonomy.tsv

●dna-sequences.fasta

#### 2️⃣ Install & Run PICRUSt2

Installation (Conda)

```bash
conda create -n picrust2 -c conda-forge -c bioconda picrust2
conda activate picrust2
```

Verify installation:

```bash
picrust2_pipeline.py -h
```

Run PICRUSt2

```bash
picrust2_pipeline.py \
  -s dna-sequences.fasta \
  -i feature-table.tsv \
  -o picrust2_out \
  -p 6
```

#### 3️⃣ Install & Run Tax4Fun2

Installation (R)

```r
install.packages("devtools")
devtools::install_github("MuStA-KIT/Tax4Fun2")
```

**Download reference database:**

🔗 https://github.com/ChiLiubio/microeco_extra_data/releases

File: Tax4Fun2_ReferenceData_v2.zip

Unzip and place into a folder, e.g.:
📁 Tax4Fun2_ReferenceData_v2/

**Run Tax4Fun2 using microeco**

```r
library(microeco)
library(Tax4Fun)

t4f <- trans_func$new(meco_physeq_ra)
t4f$for_what <- "prok"

t4f$cal_tax4fun2(
  blast_tool_path = "/path/to/blast/bin/",
  path_to_reference_data = "Tax4Fun2_ReferenceData_v2"
)
```

#### 4️⃣ Install & Run FAPROTAX

Installation

```bash
pip install faprotax
```

OR use Microeco (recommended):
Run FAPROTAX using microeco

```r
t_func <- trans_func$new(meco_physeq_ra)
t_func$for_what <- "prok"

t_func$cal_spe_func(prok_database = "FAPROTAX")
t_func$cal_func()
t_func$cal_func_FR()
t_func$cal_spe_func_perc()
```

**🎉 All done!**

Proceed to visualization using:

● picrust2_plot.R

● tax4fun_plot.R

● faprotax_plot.R
