#!/usr/bin/env Rscript
#' Build modeling features from DILI gold-standard SMILES + labels (R + rcdk only).
#'
#' Prerequisites:
#'   - Java JDK or JRE installed (rJava/rcdk require a JVM).
#'   - In a terminal (once): `R CMD javareconf` if R was installed before Java.
#'
#' Usage (from project root):
#'   Rscript scripts/featurize_dili.R
#'
#' Input:  data/DILI_Goldstandard_1111.csv  (columns smiles_r, TOXICITY)
#' Output: data/dili_modeling_features.csv.gz
#'
#' Fingerprints: CDK circular ECFP4, bit mode (analogous to Morgan radius-2 style).
#' Descriptors: CDK molecular descriptors (stable `desc_*` column names for modeling).
#'   Note: `desc_NumAromaticRings` is filled from CDK
#'   AromaticAtomsCountDescriptor (aromatic atom count, not ring count). `desc_qed`
#'   is not computed by CDK and is set to NA.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(purrr)
  library(rcdk)
  library(fingerprint)
})

args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[startsWith(args, "--file=")])
if (!nzchar(file_arg)) {
  stop("Run with: Rscript scripts/featurize_dili.R", call. = FALSE)
}
root <- normalizePath(file.path(dirname(file_arg), ".."))
raw_path <- file.path(root, "data", "DILI_Goldstandard_1111.csv")
out_path <- file.path(root, "data", "dili_modeling_features.csv.gz")

descriptor_classes <- c(
  "org.openscience.cdk.qsar.descriptors.molecular.WeightDescriptor",
  "org.openscience.cdk.qsar.descriptors.molecular.XLogPDescriptor",
  "org.openscience.cdk.qsar.descriptors.molecular.TPSADescriptor",
  "org.openscience.cdk.qsar.descriptors.molecular.HBondDonorCountDescriptor",
  "org.openscience.cdk.qsar.descriptors.molecular.HBondAcceptorCountDescriptor",
  "org.openscience.cdk.qsar.descriptors.molecular.RotatableBondsCountDescriptor",
  "org.openscience.cdk.qsar.descriptors.molecular.RingCountDescriptor",
  "org.openscience.cdk.qsar.descriptors.molecular.AromaticAtomsCountDescriptor",
  "org.openscience.cdk.qsar.descriptors.molecular.FractionalCSP3Descriptor",
  "org.openscience.cdk.qsar.descriptors.molecular.HeavyAtomCountDescriptor",
  "org.openscience.cdk.qsar.descriptors.molecular.HeteroAtomCountDescriptor",
  "org.openscience.cdk.qsar.descriptors.molecular.BertzCTDescriptor"
)

desc_output_names <- c(
  "desc_MolWt",
  "desc_MolLogP",
  "desc_TPSA",
  "desc_NumHDonors",
  "desc_NumHAcceptors",
  "desc_NumRotatableBonds",
  "desc_RingCount",
  "desc_NumAromaticRings",
  "desc_FractionCSP3",
  "desc_NumHeavyAtoms",
  "desc_NumHeteroatoms",
  "desc_BertzCT"
)

fp_bits_vector <- function(fp) {
  n <- as.integer(fp@nbit)
  b <- fp@bits
  if (length(b) == n) {
    return(as.numeric(b))
  }
  v <- integer(n)
  for (i in as.integer(b)) {
    if (is.na(i)) {
      next
    }
    if (i >= 1L && i <= n) {
      v[i] <- 1L
    } else if (i >= 0L && i < n) {
      v[i + 1L] <- 1L
    }
  }
  as.numeric(v)
}

featurize_one <- function(smi, label) {
  smi <- trimws(as.character(smi))
  if (!nzchar(smi)) {
    return(NULL)
  }
  mol <- tryCatch(
    parse.smiles(smi)[[1]],
    error = function(e) NULL
  )
  if (is.null(mol)) {
    return(NULL)
  }

  smi_canon <- tryCatch(
    get.smiles(mol, flavor = smiles.flavors(c("Canonical", "UseAromaticSymbols"))),
    error = function(e) NA_character_
  )
  if (is.na(smi_canon) || !nzchar(smi_canon)) {
    return(NULL)
  }

  desc_df <- tryCatch(
    eval.desc(list(mol), descriptor_classes),
    error = function(e) NULL
  )
  if (is.null(desc_df) || nrow(desc_df) != 1L) {
    return(NULL)
  }
  names(desc_df) <- desc_output_names

  fp <- tryCatch(
    get.fingerprint(
      mol,
      type = "circular",
      fp.mode = "bit",
      circular.type = "ECFP4",
      depth = 2
    ),
    error = function(e) NULL
  )
  if (is.null(fp)) {
    return(NULL)
  }
  fpv <- fp_bits_vector(fp)
  fp_cols <- paste0("fp_", sprintf("%03d", seq_along(fpv) - 1L))
  fp_row <- as.list(fpv)
  names(fp_row) <- fp_cols

  c(
    as.list(desc_df[1, , drop = FALSE]),
    list(desc_qed = NA_real_),
    fp_row,
    list(
      label = as.integer(label),
      smiles_canon = smi_canon
    )
  )
}

main <- function() {
  if (!file.exists(raw_path)) {
    stop("Missing input: ", raw_path, call. = FALSE)
  }

  raw <- read_csv(raw_path, show_col_types = FALSE)
  if (!all(c("smiles_r", "TOXICITY") %in% names(raw))) {
    stop("Expected columns smiles_r and TOXICITY", call. = FALSE)
  }

  rows <- pmap(
    list(raw$smiles_r, raw$TOXICITY),
    function(s, y) featurize_one(s, y)
  )
  rows <- compact(rows)
  if (length(rows) == 0L) {
    stop("No valid molecules; check Java/rcdk and SMILES input.", call. = FALSE)
  }

  out <- bind_rows(rows) |>
    distinct(smiles_canon, .keep_all = TRUE)

  write_csv(out, out_path)
  message(
    "Wrote ", out_path, " with shape ", paste(dim(out), collapse = " x "),
    "; label prevalence ", sprintf("%.3f", mean(out$label, na.rm = TRUE))
  )
}

main()
