.DEFAULT_GOAL := help

.PHONY: help setup hooks lint lint-all unit-test test test-debug test-vpn

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

test-vpn: ## Run VPN script blackbox tests
	deno test --allow-all --no-lock --quiet tests/vpn_test.ts

unit-test: ## Run e2e unit tests
	uv run --project e2e python -m unittest discover -s e2e/src -p 'test_*.py' -v

test: ## Run e2e tests in fresh Tart VM
	uv run --project e2e dotfiles-e2e

test-debug: ## Run e2e tests, keep VM on failure
	uv run --project e2e dotfiles-e2e --keep
