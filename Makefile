# =============================================================================
# Makefile for Stats 2 Quiz 1 — Group 01
# =============================================================================
# Usage:
#   make          — Run all R scripts, then compile LaTeX report
#   make data     — Run data prep & EDA only (P1)
#   make models   — Run all model-fitting scripts (P2, P3, P5)
#   make report   — Compile LaTeX to PDF only (assumes outputs exist)
#   make clean    — Remove generated files
#
# Prerequisites: R, Rscript, latexmk, pdflatex (or xelatex) on PATH
# =============================================================================

# Directories
R_DIR     := R_models
OUT_DIR   := output
FIG_DIR   := $(OUT_DIR)/figures
TAB_DIR   := $(OUT_DIR)/tables
RPT_DIR   := report

# R scripts in execution order
SETUP     := $(R_DIR)/setup.R
DATA_EDA  := $(R_DIR)/01_data_prep_eda.R
OLS       := $(R_DIR)/02_ols.R
RIDGE     := $(R_DIR)/02_ridge.R
LASSO     := $(R_DIR)/02_lasso.R
COMPARE   := $(R_DIR)/02_comparison.R
ENET      := $(R_DIR)/04_enet.R
NEURAL    := $(R_DIR)/04_neural.R
HOLDOUT   := $(R_DIR)/04_holdout.R

# Shared data file (output of Phase 1)
SHARED_DATA := $(OUT_DIR)/shared_data.RData

# Final PDF
PDF := $(RPT_DIR)/main.pdf

# =============================================================================
# Phony targets
# =============================================================================
.PHONY: all data models report clean help

all: data models report

help:
	@echo "Available targets:"
	@echo "  make          - Build everything (data -> models -> report)"
	@echo "  make data     - Run data prep and EDA (Phase 1)"
	@echo "  make models   - Run all model scripts (Phase 2-3)"
	@echo "  make report   - Compile LaTeX report to PDF"
	@echo "  make clean    - Remove generated outputs"

# =============================================================================
# Phase 1: Data preparation and EDA
# =============================================================================
data: $(SHARED_DATA)

$(SHARED_DATA): $(DATA_EDA) $(SETUP) data/fat.csv
	@echo "=== Phase 1: Data preparation and EDA ==="
	Rscript $(DATA_EDA)

# =============================================================================
# Phase 2: Model fitting (depends on shared data)
# =============================================================================
# OLS
$(OUT_DIR)/ols_fit.RData: $(OLS) $(SETUP) $(SHARED_DATA)
	@echo "=== Running OLS ==="
	Rscript $(OLS)

# Ridge
$(OUT_DIR)/ridge_fit.RData: $(RIDGE) $(SETUP) $(SHARED_DATA)
	@echo "=== Running Ridge ==="
	Rscript $(RIDGE)

# Lasso
$(OUT_DIR)/lasso_fit.RData: $(LASSO) $(SETUP) $(SHARED_DATA)
	@echo "=== Running Lasso ==="
	Rscript $(LASSO)

# Comparison (depends on all three model fits)
$(FIG_DIR)/fig_p2_comparison.pdf: $(COMPARE) $(SETUP) $(SHARED_DATA) \
    $(OUT_DIR)/ols_fit.RData $(OUT_DIR)/ridge_fit.RData $(OUT_DIR)/lasso_fit.RData
	@echo "=== Running Model Comparison ==="
	Rscript $(COMPARE)

# Elastic Net
$(OUT_DIR)/enet_fits.RData: $(ENET) $(SETUP) $(SHARED_DATA)
	@echo "=== Running Elastic Net ==="
	Rscript $(ENET)

# Neural Features
$(OUT_DIR)/neural_fits.RData: $(NEURAL) $(SETUP) $(SHARED_DATA)
	@echo "=== Running Neural Features ==="
	Rscript $(NEURAL)

# Final Holdout (depends on everything)
$(TAB_DIR)/tab_p4_holdout.tex: $(HOLDOUT) $(SETUP) $(SHARED_DATA) \
    $(OUT_DIR)/ols_fit.RData $(OUT_DIR)/ridge_fit.RData $(OUT_DIR)/lasso_fit.RData \
    $(OUT_DIR)/enet_fits.RData $(OUT_DIR)/neural_fits.RData
	@echo "=== Running Final Holdout Evaluation ==="
	Rscript $(HOLDOUT)

models: $(OUT_DIR)/ols_fit.RData \
        $(OUT_DIR)/ridge_fit.RData \
        $(OUT_DIR)/lasso_fit.RData \
        $(FIG_DIR)/fig_p2_comparison.pdf \
        $(OUT_DIR)/enet_fits.RData \
        $(OUT_DIR)/neural_fits.RData \
        $(TAB_DIR)/tab_p4_holdout.tex

# =============================================================================
# Phase 3: LaTeX compilation
# =============================================================================
report: $(PDF)

$(PDF): $(RPT_DIR)/main.tex $(RPT_DIR)/preamble.sty $(RPT_DIR)/references.bib \
        $(wildcard $(RPT_DIR)/sections/*.tex) $(wildcard $(RPT_DIR)/appendices/*.tex)
	@echo "=== Compiling LaTeX report ==="
	cd $(RPT_DIR) && latexmk -xelatex -interaction=nonstopmode main.tex

# =============================================================================
# Clean
# =============================================================================
clean:
	@echo "=== Cleaning generated files ==="
	-rm -f $(OUT_DIR)/*.RData
	-rm -f $(FIG_DIR)/*.pdf $(FIG_DIR)/*.png
	-rm -f $(TAB_DIR)/*.tex
	cd $(RPT_DIR) && latexmk -C main.tex 2>/dev/null || true
