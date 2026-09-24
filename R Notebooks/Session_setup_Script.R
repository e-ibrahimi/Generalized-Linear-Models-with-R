## =============================================================================
## GLMs for Applied Research — Environment Setup Script
## -----------------------------------------------------------------------------
## Run this ONCE before Day 1, and re-run any time you switch machines.
## It installs every package used across the hands-on lab notebooks:
##
## It then loads each package and does a quick smoke-test of every dataset the
## labs use, so you find out about problems now — not mid-session.
## =============================================================================

## Use a fast, reliable CRAN mirror for installs
options(repos = c(CRAN = "https://cloud.r-project.org"))

## -----------------------------------------------------------------------------
## 1. Package lists (grouped by which lab needs them)
## -----------------------------------------------------------------------------

pkgs_by_session <- list(
  "Session 3 - Binary classifier (Pima diabetes)"      = c("MASS", "tidyverse", "pROC", "car", "broom"),
  "Session 4 - Poisson regression (esoph)"              = c("MASS", "tidyverse", "broom"),
  "Session 7 - Multinomial & ordinal logit"             = c("nnet", "MASS", "car", "vcd", "vcdExtra", "AER"),
  "Session 9 - Mixed-effects GLMs"                      = c("lme4", "car", "performance", "HSAUR3")
)

## Optional packages: each lab has a graceful fallback if these are missing,
## but installing them now unlocks the bonus/diagnostic sections in-session.
optional_pkgs_by_session <- list(
  "Session 7 bonus - Brant test & partial proportional odds" = c("brant", "VGAM"),
  "Session 9 - simulation-based residual diagnostics"        = c("DHARMa")
)

core_packages     <- sort(unique(unlist(pkgs_by_session)))
optional_packages <- sort(unique(unlist(optional_pkgs_by_session)))

cat("=============================================================\n")
cat("GLM Seminar — installing", length(core_packages), "required package(s)\n")
cat("and", length(optional_packages), "optional package(s)\n")
cat("=============================================================\n\n")

## -----------------------------------------------------------------------------
## 2. Helper: install only what's missing, one package at a time so a single
##    failure doesn't abort the whole run
## -----------------------------------------------------------------------------

install_if_missing <- function(pkgs) {
  installed <- rownames(installed.packages())
  to_install <- setdiff(pkgs, installed)

  if (length(to_install) == 0) {
    cat("  All already installed:", paste(pkgs, collapse = ", "), "\n")
    return(invisible(NULL))
  }

  for (pkg in to_install) {
    cat("  Installing", pkg, "...\n")
    tryCatch(
      install.packages(pkg, dependencies = TRUE),
      error = function(e) {
        cat("    FAILED to install", pkg, "-", conditionMessage(e), "\n")
      }
    )
  }
}

cat("Installing required packages:\n")
install_if_missing(core_packages)

cat("\nInstalling optional packages (safe to skip if these fail):\n")
for (pkg in optional_packages) {
  tryCatch(
    install_if_missing(pkg),
    error = function(e) cat("  Skipping", pkg, "-", conditionMessage(e), "\n")
  )
}

## -----------------------------------------------------------------------------
## 3. Load every required package and report a pass/fail checklist
## -----------------------------------------------------------------------------

cat("\n=============================================================\n")
cat("Loading required packages\n")
cat("=============================================================\n")

load_status <- sapply(core_packages, function(pkg) {
  ok <- suppressWarnings(suppressPackageStartupMessages(
    require(pkg, character.only = TRUE, quietly = TRUE)
  ))
  cat(sprintf("  [%s] %s\n", ifelse(ok, "OK", "MISSING"), pkg))
  ok
})

if (any(!load_status)) {
  cat("\nSome required packages failed to load:",
      paste(names(load_status)[!load_status], collapse = ", "), "\n")
  cat("Try running install.packages() for those manually before Day 1.\n")
} else {
  cat("\nAll required packages loaded successfully.\n")
}

cat("\nOptional packages (a missing one just disables a bonus section):\n")
for (pkg in optional_packages) {
  ok <- suppressWarnings(suppressPackageStartupMessages(
    requireNamespace(pkg, quietly = TRUE)
  ))
  cat(sprintf("  [%s] %s\n", ifelse(ok, "OK", "not installed"), pkg))
}

## -----------------------------------------------------------------------------
## 4. Smoke-test every dataset the labs use
##    (all ship inside packages above — nothing needs to be downloaded)
## -----------------------------------------------------------------------------

cat("\n=============================================================\n")
cat("Checking lab datasets load correctly\n")
cat("=============================================================\n")

dataset_checks <- list(
  "Session 3 - Pima.tr / Pima.te (MASS)" = function() {
    data(Pima.tr, package = "MASS"); data(Pima.te, package = "MASS")
    stopifnot(nrow(Pima.tr) > 0, nrow(Pima.te) > 0)
  },
  "Session 4 - esoph (base datasets)" = function() {
    data(esoph); stopifnot(nrow(esoph) > 0)
  },
  "Session 7 - Alligator (vcdExtra)" = function() {
    data(Alligator, package = "vcdExtra"); stopifnot(nrow(Alligator) > 0)
  },
  "Session 7 - Arthritis (vcd)" = function() {
    data(Arthritis, package = "vcd"); stopifnot(nrow(Arthritis) > 0)
  },
  "Session 7 bonus - NMES1988 (AER)" = function() {
    data(NMES1988, package = "AER"); stopifnot(nrow(NMES1988) > 0)
  },
  "Session 9 - cbpp (lme4)" = function() {
    data(cbpp, package = "lme4"); stopifnot(nrow(cbpp) > 0)
  },
  "Session 9 - grouseticks (lme4)" = function() {
    data(grouseticks, package = "lme4"); stopifnot(nrow(grouseticks) > 0)
  }
)

for (label in names(dataset_checks)) {
  result <- tryCatch({
    dataset_checks[[label]]()
    "OK"
  }, error = function(e) paste("FAILED -", conditionMessage(e)))
  cat(sprintf("  [%s] %s\n", ifelse(result == "OK", "OK", "FAILED"), label))
  if (result != "OK") cat("      ", result, "\n")
}

## -----------------------------------------------------------------------------
## 5. Final summary
## -----------------------------------------------------------------------------

cat("\n=============================================================\n")
if (all(load_status)) {
  cat("Setup complete — your environment is ready for the seminar.\n")
} else {
  cat("Setup finished with issues — see the [MISSING] lines above.\n")
  cat("Re-run this script after resolving them, or install manually:\n")
  cat("  install.packages(c(\"", paste(names(load_status)[!load_status], collapse = "\", \""), "\"))\n", sep = "")
}
cat("=============================================================\n")

## Uncomment to record full session details (R version, package versions, OS)
## useful when troubleshooting on the day:
# sessionInfo()
