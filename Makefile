.PHONY: help %
.DEFAULT_GOAL := help
SHELL := bash
.EXPORT_ALL_VARIABLES:

help:
	@echo "Makefile is deprecated; use Taskfile instead."
	@echo "Listing available tasks (if Task is installed):"
	@command -v task >/dev/null 2>&1 && task -l || { \
	  echo "Task is required: https://taskfile.dev/#/installation"; \
	  echo "macOS: brew install go-task/tap/go-task"; \
	}

%:
	@command -v task >/dev/null 2>&1 || { \
	  echo "Task is required but not found."; \
	  echo "Install: https://taskfile.dev/#/installation (macOS: brew install go-task/tap/go-task)"; \
	  exit 2; \
	}
	@task $@
