# CDS 101 — Final project: Liver Labs (DILI classification)

Computational–data-science capstone: **binary classification** of drug-induced liver injury (DILI) concern from **SMILES-derived** molecular features, with full documentation in **`final_report.Rmd`**.

## Team

| Member    | GitHub        |
|-----------|---------------|
| Zamir     | [ZamirOsmanzai](https://github.com/ZamirOsmanzai) |
| Usman     | [Usaleem16](https://github.com/Usaleem16) |
| Kebron    | [bizabebron-ops](https://github.com/bizabebron-ops) |

## Repository layout

| Path | Purpose |
|------|---------|
| `final_report.Rmd` | **Main write-up** (rubric-aligned: problem, data, cleaning, EDA, viz, modeling, conclusions, reproducibility). |
| `proposal.Rmd` | Submitted-style proposal (HTML via Knit). |
| `data/DILI_Goldstandard_1111.csv` | Raw SMILES + labels ([source](https://github.com/srijitseal/DILI)). |
| `data/dili_modeling_features.csv.gz` | Parsed + featurized modeling table (regenerate with script below). |
| `scripts/featurize_dili.R` | Featurization in R with `rcdk` (CDK + Java). |
| `install_packages.R` | R package bootstrap for `tidymodels`, `ranger`, `glmnet`, etc. |
| `CDS101_Project.Rproj` | Open in RStudio. |

Starter templates (`*_template.Rmd`) and the other paths above (except `final_report.Rmd`) largely match the CDS 101 starter zip. Custom work is concentrated in **`final_report.Rmd`**; the git history reflects that (see below).

## Git history (what each `Task` commit is)

| Commit | What it contains |
|--------|-------------------|
| **Task 1** | Starter/course bundle only: project files, templates, `data/`, `scripts/`, `githooks/`, `proposal.Rmd`, EDA notebook, etc. **No** `final_report.Rmd`. |
| **Task 2** | `final_report.Rmd`: YAML, setup chunk, Problem definition (questions, objectives, assumptions). |
| **Task 3** | Adds Data acquisition & description (raw data chunks + ethics). |
| **Task 4** | Adds Data cleaning & preprocessing + `load-features` summary. |
| **Task 5** | Adds EDA: class balance plot and interpretation. |
| **Task 6** | Adds EDA: descriptor boxplots, correlation heatmap, and narrative. |
| **Task 7** | Adds Visualization quality and storytelling section. |
| **Task 8** | Adds Modeling approach (baselines, feature sets, train/test split). |
| **Task 9** | Adds Model implementation: prep chunk (recipes, `tune_lr`, curve helpers). |
| **Task 10** | Adds Tuned ridge models + random forest fit chunks. |
| **Task 11** | Adds Majority baseline, metrics table, and metric glossary. |
| **Task 12** | Adds ROC, precision-recall, variable importance, and confusion matrix chunks. |
| **Task 13** | Adds Conclusions, reproducibility, references, and appendix. |
| **Task 14** | This `README.md` (project overview and instructions). |

## Reproduce

1. In R: `source("install_packages.R")`
2. (Optional) Rebuild features: `Rscript scripts/featurize_dili.R` (needs Java; see `data/README.md`).
3. Knit the final report: `final_report.Rmd` matches the template (`html_document` + `gmu-cds101.css`, and `pdf_document` with XeLaTeX). From the project root run `make report-html` → `reports/final_report.html` and/or `make report-pdf` → `reports/final_report.pdf`, or use RStudio **Knit** (first output format is HTML unless you change the knit target).  
   `make proposal-html` → `reports/proposal.html` if you need the proposal as HTML.

Optional: run once in this repo to drop Cursor co-author lines from future commits: `git config core.hooksPath githooks`

Generated outputs under `reports/` may be listed in `.gitignore`; generate them before submission if your course expects committed artifacts.

## RStudio: “Error while opening file” (No such file or directory)

That usually means RStudio’s **Files** pane or a **restored tab** still points at an **old folder** (for example after renaming `cds101_starter_kit` → `cds101-finalproj-LiverLabs`).

1. **Quit RStudio fully** (macOS: **RStudio → Quit RStudio**, not only closing the window).
2. From Terminal, in this project directory, run:  
   `bash scripts/reset_rstudio_cache.sh`  
   (This deletes only **`.Rproj.user/`**, local UI state; your `.Rmd` and data are untouched.)
3. Open the project again with **`CDS101_Project.Rproj`** in **`Documents/R/cds101-finalproj-LiverLabs`**.
4. Avoid **File → Recent Files** entries that still show the old path; use **File → Open File…** if needed.

## Methods snapshot

- **Features:** physicochemical descriptors + circular fingerprints (CDK via `rcdk` in R).  
- **Models:** tuned **ridge logistic regression** (three feature sets) and tuned **random forest** (combined).  
- **Evaluation:** stratified hold-out + **ROC / PR curves**, confusion matrix, permutation importance.

This goes beyond typical lab exercises by combining **external cheminformatics featurization**, **high-dimensional regularized models**, **non-linear ensembles**, and **multi-metric** assessment grounded in **molecular** and **biomedical** framing.

<!-- CDS 101 final submission bundle -->
