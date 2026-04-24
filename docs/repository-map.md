# Repository Map

This file is a quick navigation aid for maintainers.

- `templates/`: Opinionated starter files for new scripts and shared patterns.
- `utils/`: Sourced helper libraries.
- `01-basics/` to `10-sre-usecases/`: Operational domains with executable scripts and paired docs.
- `projects/`: Complete examples that demonstrate orchestration across multiple tasks.
- `.github/workflows/`: CI checks for linting, syntax, and docs parity.

When adding a new script:

1. Start from `templates/script_template.sh`.
2. Source `utils/common.sh` and any other helper needed.
3. Add a same-name `.md` file next to the script.
4. Run the local validation commands from the root README.
