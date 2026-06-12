## 🧰 Training Your Own QIIME2 Classifier

Machine-learning taxonomic classification in QIIME2 uses a Naïve Bayes classifier trained on reference sequences + taxonomy labels.
While pre-trained classifiers (SILVA, UNITE, PR2, MIDORI, GTDB) work well in most cases, training your own classifier can substantially improve accuracy under certain conditions.

**⭐ When Do You Need to Train Your Own Classifier?**
● You do NOT need custom training when:

● You use standard primer sets (e.g., 515F–806R, V4 region).

● You use Illumina 2×250 or 2×150 paired-end.

● You use SILVA full-length pre-trained classifier.

**You SHOULD train a custom classifier when:**

✔ Your primers target only a sub-region (e.g., ITS2 only, V3–V4, V1–V2)
✔ You expect short reads
✔ You use unusual or modified primers
✔ You notice too many “Unassigned” sequences
✔ Mismatched databases cause misclassification
✔ You want taxonomy consistent with MAGs (GTDB)

#### 🧬 Training a Classifier with SILVA 132 (Example)

Modify paths as needed.
**1. Download SILVA Reference Sequences + Taxonomy**

```bash
wget https://data.qiime2.org/2020.6/common/silva-132-99-seqs.qza
wget https://data.qiime2.org/2020.6/common/silva-132-99-tax.qza
```

**2. Extract the Region Matching Your 18S Primers**

Example for Stoeck et al. 2010 18S V4 region
(primers you provided):

● Forward: GTACACACCGCCCGTC

● Reverse: TGATCCTTCTGCAGGTTCACCTAC

```bash
qiime feature-classifier extract-reads \
  --i-sequences silva-132-99-seqs.qza \
  --p-f-primer GTACACACCGCCCGTC \
  --p-r-primer TGATCCTTCTGCAGGTTCACCTAC \
  --o-reads ref-seqs-18S-V4.qza
```

**3. Train the Classifier**

```bash
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads ref-seqs-18S-V4.qza \
  --i-reference-taxonomy silva-132-99-tax.qza \
  --o-classifier silva-132-18S-V4-classifier.qza
```

⭐ Correct 16S Users Should Use SILVA 138 or 138.1 Instead

If your target is 16S, you should train using:

SILVA 138.1 (full-length 16S)

GTDB (if you need MAG-aligned bacterial taxonomy)

#### 🧬 Classifier Summary Table

| Marker  | Best Database for Training | Notes                                 |
| ------- | -------------------------- | ------------------------------------- |
| **16S** | SILVA 138.1, GTDB          | GTDB aligns with MAG taxonomy         |
| **ITS** | UNITE                      | ITS1/ITS2 specific                    |
| **18S** | **SILVA 132**, PR2         | PR2 provides best eukaryotic taxonomy |
| **12S** | MitoFish                   | Vertebrate barcode                    |
| **COI** | MIDORI, BOLD               | Animal DNA barcoding                  |

#### 📌 Note on GTDB Classifiers

Advantages

● Genome-based taxonomy

● Matches MAGs and metagenome analyses

● Includes uncultured candidate taxa (UBAxxxx, etc.)

**Limitations**

● Not optimized for amplicons

● Requires custom processing

● Fewer tutorials/examples online

● Use GTDB-based classifiers if your downstream analyses involve MAGs.

🎉 Final Recommendation

Use the pre-trained SILVA classifier unless you have a specific reason to train your own.
Custom classifiers are more precise — but require more computation, care, and testing.
