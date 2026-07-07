# gwasplot developer CLI
# Usage: `make <target>` (run `make help` to list targets).

R      ?= Rscript
PKG    := $(shell awk '/^Package:/{print $$2}' DESCRIPTION)
VER    := $(shell awk '/^Version:/{print $$2}' DESCRIPTION)
TARBALL = $(PKG)_$(VER).tar.gz

.DEFAULT_GOAL := help
.PHONY: help document test check check-fast build install site site-preview data clean

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

document: ## Regenerate Rd docs and NAMESPACE from roxygen comments
	$(R) -e 'roxygen2::roxygenise()'

test: ## Run the testthat suite
	$(R) -e 'devtools::test()'

check: document ## Full R CMD check (builds the vignette)
	$(R) -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "warning")'

check-fast: ## Quick R CMD check (skip vignettes, manual and tests)
	$(R) -e 'rcmdcheck::rcmdcheck(args = c("--no-manual","--no-build-vignettes","--no-tests"))'

build: document ## Build the source tarball ($(TARBALL))
	$(R) -e 'devtools::build()'

install: document ## Install the package locally
	$(R) -e 'devtools::install(upgrade = "never")'

data: ## Regenerate the bundled example datasets
	$(R) -e 'source("data-raw/make_example_data.R")'

site: document ## Build the pkgdown website into docs/
	$(R) -e 'pkgdown::build_site(preview = FALSE)'

site-preview: ## Build and open the pkgdown site in a browser
	$(R) -e 'pkgdown::build_site()'

clean: ## Remove build artefacts (docs/, tarballs, check dir)
	rm -rf docs/ $(PKG).Rcheck/ $(PKG)_*.tar.gz
