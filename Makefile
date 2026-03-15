.DEFAULT_GOAL := help

.PHONY: help setup hooks lint lint-all

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: hooks ## Run full local setup
	@echo "Setup complete."

hooks: ## Install prek git hooks
	.hermit/bin/prek install

lint: ## Run prek hooks on staged/changed files
	.hermit/bin/prek run

lint-all: ## Run prek hooks on all files
	.hermit/bin/prek run --all-files
