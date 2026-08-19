.PHONY: restore check analysis verify reproduce report

restore:
	Rscript --vanilla scripts/restore.R

check:
	Rscript --vanilla scripts/ci_check.R

analysis:
	Rscript --vanilla analysis/00_run_all.R

verify:
	Rscript --vanilla scripts/validate_outputs.R

reproduce:
	Rscript --vanilla scripts/reproduce.R

report:
	Rscript --vanilla scripts/reproduce.R --report
