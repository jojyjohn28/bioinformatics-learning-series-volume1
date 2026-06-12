## 🧰 Removing Contamination in Amplicon Sequencing (Marker-Specific Filtering)

After taxonomy assignment, you must filter out non-target sequences that do not belong in the biological community you are profiling.

Sources of contamination include:

● Host DNA (plants, animals, humans)

● Mitochondria & chloroplasts

● Environmental carryover

● Off-target amplification

Filtering rules depend entirely on the marker gene.

#### 🔬 Marker-Specific Contaminant Removal

**1️⃣ 16S rRNA (Bacteria + Archaea)**

Remove:

● Mitochondria

● Chloroplasts

● Eukaryotic sequences

These often appear due to universal primer binding.

**2️⃣ ITS (Fungi)**

Remove:

● Bacteria

● Archaea

● Chloroplasts

● Mitochondria

● Non-fungal eukaryotes (protists, plants)

ITS is highly variable and prone to off-target amplification.

**3️⃣ 18S rRNA (Eukaryotes / Protists)**

Remove:

● Bacteria

● Archaea

● Fungi (optional depending on the study)

● Host sequences (Metazoa)

You may selectively include/exclude fungi or metazoa depending on the objective.

**4️⃣ 12S rRNA (Vertebrates / eDNA)**

Remove:

● Invertebrates

● Microbes

● Plants

● Fungi

MiFish primers are designed for vertebrates but may amplify non-targets.

**5️⃣ COI (Metazoa / Barcoding)**

Remove:

● Bacteria

● Archaea

● Fungi

● Plants

COI is a mitochondrial marker — interpret carefully with respect to host DNA.

#### ⚙️ QIIME2 Filtering Commands (Modify Per Marker)

16S example

```bash
qiime taxa filter-table \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-table table-no-contam.qza
```

Filter sequences too:

```bash
qiime taxa filter-seqs \
  --i-sequences rep-seqs.qza \
  --i-taxonomy taxonomy.qza \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-sequences rep-seqs-no-contam.qza
```

#### 📌 Marker-Specific Variants

ITS (keep fungi only):

```bash
--p-include k__Fungi
```

18S (keep protists only):

```bash
--p-include k__Eukaryota \
--p-exclude k__Fungi,k__Metazoa
```

12S (vertebrates only):

```bash
--p-include Vertebrata
```

COI (Invertebrates only):

```bash
--p-include k__Animalia \
--p-exclude k__Fungi,k__Plantae
```

#### 📝 Summary Table

| Marker | Keep              | Remove                     |
| ------ | ----------------- | -------------------------- |
| 16S    | Bacteria, Archaea | Chloroplast, mitochondria  |
| ITS    | Fungi             | Plants, protists, bacteria |
| 18S    | Protists          | Microbes, host DNA         |
| 12S    | Vertebrates       | Invertebrates, microbes    |
| COI    | Metazoa           | Plants, fungi, microbes    |
