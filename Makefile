SHELL := /usr/bin/env bash
SCRIPTS := $(shell find . -type f -name '*.sh' | sort)

.PHONY: lint validate docs-check

lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck is required"; exit 1; }
	@shellcheck $(SCRIPTS)

validate:
	@for script in $(SCRIPTS); do bash -n "$$script"; done

docs-check:
	@for script in $(SCRIPTS); do     		doc="$${script%.sh}.md";     		[[ -f "$$doc" ]] || { echo "Missing documentation for $$script"; exit 1; };     	done
