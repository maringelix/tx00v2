# tx00v2 harness entry points. CI runs exactly these targets (see docs/HARNESS.md).
SHELL := bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

HARNESS := bash scripts/harness.sh

.PHONY: help tools static family verify all clean

help: ## Show the available targets
	@awk 'BEGIN { FS = ":.*## " } /^[a-z][a-z-]*:.*## / { printf "  %-8s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

tools: ## Install the pinned harness tools into .tools/ (SHA256-verified)
	@bash scripts/install-tools.sh

static: ## Structure, identifiers, workflow policy, links, roadmap format, actionlint, shellcheck, gitleaks
	@$(HARNESS) static

family: ## Cross-repo checks of the six lab repositories (network, or FAMILY_SOURCE=<dir with checkouts>)
	@$(HARNESS) family

verify: ## The required gate: static (CI job static)
	@$(HARNESS) static

all: ## static + family
	@$(HARNESS) all

clean: ## Remove installed tools and harness scratch data (family clones included)
	@rm -rf .tools .cache
	@rm -rf "$${TMPDIR:-/tmp}/tx00v2-harness"
