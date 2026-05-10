# Makefile for CDS 101 RMarkdown project (v2)
# Requires: R, rmarkdown, LaTeX (e.g. tinytex) for PDF
# Targets:
#   make eda           - knit notebooks/eda_walkthrough.Rmd
#   make report-html   - knit final_report.Rmd to HTML in reports/
#   make report-pdf    - knit final_report.Rmd to PDF in reports/ (primary deliverable)
#   make proposal-html - knit proposal.Rmd to HTML in reports/
#   make featurize     - Rscript scripts/featurize_dili.R (needs Java + rcdk)

RSCRIPT ?= Rscript

eda:
	$(RSCRIPT) -e "rmarkdown::render('notebooks/eda_walkthrough.Rmd', output_dir = 'notebooks')"

report-html:
	$(RSCRIPT) -e "rmarkdown::render('final_report.Rmd', output_format = 'html_document', output_dir = 'reports')"

report-pdf:
	$(RSCRIPT) -e "rmarkdown::render('final_report.Rmd', output_format = 'pdf_document', output_dir = 'reports')"

proposal-html:
	$(RSCRIPT) -e "rmarkdown::render('proposal.Rmd', output_file = 'reports/proposal.html')"

clean:
	rm -f notebooks/eda_walkthrough.html notebooks/eda_walkthrough.pdf
	rm -f reports/final_report.html reports/final_report.pdf reports/proposal.html
	rm -rf reports/final_report_files reports/proposal_files final_report_files

featurize:
	$(RSCRIPT) scripts/featurize_dili.R

.PHONY: eda report-html report-pdf proposal-html clean featurize
