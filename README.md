# STAT452 Final Project - Group 8

This repository is the active workspace for STAT452 Project 03, **Wine Quality (Red)**. The supplied data contain 1,599 red wines, 11 physicochemical predictors, and the `quality` response.

The project has two required parts:

1. A supervised-learning workflow for Wine Quality (Red): EDA, cleaning, feature selection, a baseline, at least two regularized models, and held-out evaluation.
2. A separate experimental-design study using two-factor ANOVA or a `2^k` factorial design with `k >= 2`.

The current planning assumption is regression on the quality score. Confirm that decision in [TODO.md](TODO.md) before modelling.

## Group 8

| No. | Member | Student ID |
|---:|---|---:|
| 1 | Trần Lê Anh Tuấn | 24125107 |
| 2 | Nguyễn Bảo Minh Triết | 24125047 |
| 3 | Nguyễn Đình Thiên Lộc | 24125093 |
| 4 | Nguyễn Hồng Tấn Tài | 24125078 |
| 5 | Lê Minh Thuận | 24125105 |

## Repository map

| Path | Purpose |
|---|---|
| `analysis/` | Ordered R analysis scripts |
| `R/` | Shared configuration and reusable functions |
| `data/raw/` | Immutable supplied source data |
| `data/processed/` | Reproducible derived datasets |
| `output/` | Generated figures, tables, and model objects |
| `report/` | Final report source and generated PDF |
| `presentation/` | Presentation source and final deck |
| `scripts/` | Restore, reproduce, and validation commands |
| `references/` | Course briefs, group assignment, notes, and labs |
| `legacy/midterm/` | Read-only Applied Statistics II midterm history |

## What to install

Use these versions and tools on every computer:

- **R 4.5.2**, exactly as recorded in `renv.lock`.
- **Pandoc 2.0 or newer**. RStudio and Quarto normally include it.
- **MiKTeX** for the PDF report. MiKTeX supplies the `xelatex` compiler used by the report; other TeX distributions are unsupported.
- Git, if cloning the repository.
- Internet access for the first R package restore and any MiKTeX packages needed by the report.

R packages are handled by `renv`; do not install them manually before the first run. If R must compile a package, Windows needs Rtools 4.5, macOS needs Xcode Command Line Tools and compatible GNU Fortran, and Ubuntu/Debian needs `build-essential` and `gfortran`.

### MiKTeX setup

Windows:

1. Download and run the [Basic MiKTeX Installer](https://miktex.org/download).
2. Choose a private per-user installation.
3. Set **Install missing packages on-the-fly** to **Always**.
4. Close and reopen PowerShell or Command Prompt.

macOS:

1. Install MiKTeX from the [official macOS instructions](https://miktex.org/howto/install-miktex-mac).
2. Finish the private setup in MiKTeX Console and enable automatic installation of missing packages.
3. If `xelatex` is not found, add MiKTeX's private `~/bin` directory to your terminal `PATH` using the [official PATH instructions](https://miktex.org/howto/modify-path).

Linux:

Follow the commands for your distribution on the [official MiKTeX download page](https://miktex.org/download), then finish the setup and enable automatic package installation. For Ubuntu 24.04, the commands are:

```sh
sudo apt-get update
sudo apt-get install -y curl gnupg
curl -fsSL https://miktex.org/download/key | sudo gpg --dearmor -o /usr/share/keyrings/miktex.gpg
echo "deb [signed-by=/usr/share/keyrings/miktex.gpg] https://miktex.org/download/ubuntu noble universe" | sudo tee /etc/apt/sources.list.d/miktex.list
sudo apt-get update
sudo apt-get install -y miktex
sudo miktexsetup --shared=yes finish
sudo initexmf --admin --set-config-value='[MPM]AutoInstall=1'
```

#### Fedora setup

These instructions target Fedora 43 or 44 on x86-64. Install the build tools and Pandoc first:

```sh
sudo dnf install -y git curl gcc gcc-c++ gcc-gfortran make libxml2-devel pandoc
```

Fedora normally provides the newest R release, but this project requires exactly R 4.5.2. Install `rig`, then use it to install and select that version:

```sh
sudo dnf install -y https://github.com/r-lib/rig/releases/download/latest/r-rig-latest-1.$(arch).rpm
rig add 4.5.2
rig default 4.5.2
Rscript --version
```

Install MiKTeX from its Fedora repository. This example is for Fedora 44; replace `44` with `43` when using Fedora 43:

```sh
sudo rpm --import https://miktex.org/download/key
sudo curl -L -o /etc/yum.repos.d/miktex.repo https://miktex.org/download/fedora/44/miktex.repo
sudo dnf install -y miktex
sudo miktexsetup --shared=yes finish
sudo initexmf --admin --set-config-value='[MPM]AutoInstall=1'
xelatex --version
```

After cloning the repository, use the same project commands shown below. Fedora is supported by the documented tools, although the GitHub-hosted CI matrix currently tests Ubuntu, Windows, and macOS rather than Fedora.

On every operating system, open a new terminal and verify the tools before rendering:

```text
Rscript --version
pandoc --version
xelatex --version
```

The first command must report R 4.5.2. The last command should identify MiKTeX.

MiKTeX is the distribution and XeLaTeX is its Unicode-capable compiler. Therefore, `latex_engine: xelatex` in the report and `xelatex --version` in the terminal checks are intentional MiKTeX configuration, not references to another TeX distribution.

## First run from a clean clone

Open PowerShell, Command Prompt, macOS Terminal, or a Linux terminal. Clone the repository, enter its root folder, and run:

```text
git clone https://github.com/nguyendinhthienloc/Stats2.git
cd Stats2
Rscript --vanilla scripts/reproduce.R
```

That one R command:

1. bootstraps the `renv` version in `renv.lock`;
2. restores the exact locked R package versions;
3. checks the R version, dependency declarations, lockfile, repository, and dataset;
4. runs `analysis/00_run_all.R` in the required order.

To run the same workflow and render the PDF with MiKTeX:

```text
Rscript --vanilla scripts/reproduce.R --report
```

Run commands from the repository root. There is no Make requirement.

## Useful terminal commands

```text
Rscript --vanilla scripts/restore.R
Rscript --vanilla scripts/ci_check.R
Rscript --vanilla scripts/reproduce.R
Rscript --vanilla scripts/reproduce.R --report
```

In order, these restore packages, validate the project, run the full analysis, and run the full analysis plus PDF report. The same commands work in PowerShell, Command Prompt, macOS Terminal, and Linux shells.

## Why the restore is portable

`renv.lock`, `renv/activate.R`, and `.Rprofile` are tracked. The generated `renv/library/` directory is ignored. Each computer restores its own operating-system-specific project library from the same lockfile, so never copy or commit another member's `renv/library/` directory.

The R `languageserver` package is also restored by `renv`, so supported editors can provide completion, diagnostics, and navigation inside this isolated project environment.

The restore is strict and non-interactive. It fails clearly if the active R version is not 4.5.2, a declared package is absent from the lockfile, or the restored library and lockfile disagree.

## Updating R dependencies

When intentionally adding or upgrading an R package:

1. Add it to `Imports` in `DESCRIPTION`.
2. Install it in the project library:

   ```text
   Rscript -e "renv::install('package-name')"
   ```

3. Update the lockfile:

   ```text
   Rscript -e "renv::snapshot(prompt = FALSE)"
   ```

4. Re-run the project and commit `DESCRIPTION` and `renv.lock` together:

   ```text
   Rscript --vanilla scripts/reproduce.R
   ```

Do not edit `renv.lock` manually.

## Data and modelling safeguards

- Project seed: `4520803`.
- Treat `data/raw/` as immutable.
- Generate derived data under `data/processed/`.
- Fit preprocessing, feature selection, and tuning on training/resampling data only.
- Inspect held-out test outcomes only in `analysis/04_holdout_evaluation.R`.
- Run the stages through `analysis/00_run_all.R`, not in an arbitrary order.

## Continuous integration

CI runs the analysis command on Ubuntu, Windows, and macOS with R 4.5.2. A separate Ubuntu job installs MiKTeX from its official repository and runs the report command. This keeps cross-platform analysis checks fast while testing the exact documented PDF toolchain.

GitHub branch protection still must be enabled before CI can be required for merges. Submission artifacts are assembled manually after CI passes.

## Deliverables

- PDF report, at most 20 pages excluding appendices.
- Reproducible R Markdown and R source that run top-to-bottom.
- Ten-minute presentation.

See [TODO.md](TODO.md) for the requirement checklist and open decisions.
