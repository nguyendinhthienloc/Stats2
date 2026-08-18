.PHONY: all restore check analysis report clean help

R := Rscript --vanilla
REPORT := report/final-report.Rmd
REPORT_PDF := report/final-report.pdf

all: check analysis report

help:
	@echo "Targets: restore, check, analysis, report, all, clean"

restore:
	$(R) -e "if (!requireNamespace('renv', quietly=TRUE)) install.packages('renv', repos='https://cloud.r-project.org'); renv::restore(prompt=FALSE)"

check:
	$(R) scripts/ci_check.R

analysis:
	$(R) analysis/00_run_all.R

report:
	$(R) -e "renv::load(); rmarkdown::render('$(REPORT)', output_file='final-report.pdf', quiet=FALSE)"

clean:
	$(R) -e "files <- c('$(REPORT_PDF)', list.files('report', pattern='\\.(aux|bbl|bcf|blg|fdb_latexmk|fls|log|out|run.xml|synctex.gz|tex|toc|xdv)$$', full.names=TRUE)); unlink(files[file.exists(files)])"
