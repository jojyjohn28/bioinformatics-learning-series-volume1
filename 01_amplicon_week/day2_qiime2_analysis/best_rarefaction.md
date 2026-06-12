## 🧰 How to Choose the Best Rarefaction Depth in QIIME2

Rarefaction depth determines how many reads per sample are retained for diversity analyses. Choosing the wrong depth may:

❌ Remove too many samples
❌ Introduce bias
❌ Inflate or collapse diversity patterns

Correct rarefaction ensures consistent comparison across samples.

#### ⭐ Step 1: Open the DADA2 Denoising Stats

```bash
qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-stats.qzv
```

Upload denoising-stats.qzv to:https://view.qiime2.org/

#### ⭐ Step 2: Identify Minimum Non-Chimeric Reads

Check the column:

non-chimeric → final usable reads per sample
Example:
| Sample | Non-Chimeric Reads |
| ------ | ------------------- |
| S1a | 23,897 |
| S1b | 27,647 |
| S1c | 23,192 |
| S2a | 27,450 |
| S2b | 23,057 |
| S2c | 27,444 |
| S3a | 25,654 |
| S3b | **21,544** ← lowest |
| S3c | 24,701 |
Minimum = 21,544 reads.

#### ⭐ Step 3: Choose a Rarefaction Depth

General rules:

✔ Choose a depth below the lowest sample’s read count (21,544)
✔ But high enough for ecological analyses
✔ Avoid discarding samples unnecessarily

For soil microbiomes:

10k–15k reads = minimal

20k–25k reads = ideal for stable alpha/beta diversity

👉 Best rarefaction = 20,000 reads

Why?

Below the lowest sample (21,544) → keeps all samples

High enough for robust diversity analyses

Good compromise between depth and retention

#### ⭐ Conclusion

A good rarefaction depth:

✔ Retains the maximum number of samples
✔ Preserves ecological signal
✔ Minimizes bias in diversity metrics
