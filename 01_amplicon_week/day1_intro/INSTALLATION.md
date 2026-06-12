## 🧰 Amplicon Week — Day 1

### Installation Guide for Amplicon Sequencing & Metabarcoding Tools

This guide provides step-by-step instructions to install all required tools for 16S, ITS, 18S, 12S, and COI metabarcoding workflows.  
It supports **Linux**, **macOS**, **Windows (via WSL2)**, and **R environments**.

---

# 🔧 1. Install Conda or Mamba (Required)

### **Linux / macOS**

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

Install Mamba (faster package management):

```bash
conda install mamba -n base -c conda-forge
```

### **Windows Users**

Windows does not support QIIME2 natively.

You MUST install: WSL2 or virtualbox (Eg: https://www.virtualbox.org/)

##### 🔬 Install QIIME2 (Linux / macOS / WSL2)

Download the current release:

```bash
wget https://data.qiime2.org/distro/core/qiime2-2024.2-py38-linux-conda.yml
```

Create environment:

```bash
mamba env create -n qiime2-2024.2 --file qiime2-2024.2-py38-linux-conda.yml
conda activate qiime2-2024.2
```

Verify:

```bash
qiime --help
```

#### 🧬 Install DADA2 (R package)

Works on Linux, macOS, and Windows.
Open R:

```r
install.packages("BiocManager")
BiocManager::install("dada2")
```

#### Install Microeco (R package)

```r
install.packages("microeco")
```

Proceed to Day 2 for QIIME2 setup, importing data, and database training.
