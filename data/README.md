# Data for the liver toxicity (DILI) classification project

## Raw labels and structures

- `DILI_Goldstandard_1111.csv` - Expert-curated drug-induced liver injury labels with SMILES strings, from the [DILI](https://github.com/srijitseal/DILI) repository (Seal et al.; DILIst / literature sources).

## Featurized modeling table

- `dili_modeling_features.csv.gz` - One row per unique canonical structure after parsing. Columns:

  - `smiles_canon`: standardized SMILES (for traceability; excluded from fitting).
  - `desc_*`: physicochemical descriptors from CDK via `rcdk` (see `scripts/featurize_dili.R` comments for nuances).
  - `fp_*`: circular fingerprint bits from CDK (ECFP4-style); the modeling Rmd discovers columns by name prefix.
  - `label`: binary outcome (`1` = elevated DILI concern in the source taxonomy).

### Regenerating features in R

Requires a Java runtime (JDK or JRE) so `rJava` and `rcdk` can load the Chemistry Development Kit. After installing Java, run once:

```bash
sudo R CMD javareconf
```

Then in R: `source("install_packages.R")` (installs `rcdk`, `rJava`, `fingerprint`, etc.), and from the project root:

```bash
Rscript scripts/featurize_dili.R
```

This uses CDK circular fingerprints (ECFP4, bit mode, depth 2) and CDK molecular descriptors. `desc_qed` is not available from CDK and is stored as `NA`. The column `desc_NumAromaticRings` is filled from CDK’s aromatic atom count (interpret as an aromaticity-related count, not strictly “rings”).

## Relationship to the Therapeutics Data Commons (TDC)

The course proposal references the TDC DILI benchmark (~475 compounds, scaffold splits). The gold-standard file used here is larger and independently curated, but addresses the same scientific question. Methods in the report (stratified resampling, cross-validated models, ROC-AUC) align with TDC-style practice; cite both TDC and the Seal / DILIst sources.
