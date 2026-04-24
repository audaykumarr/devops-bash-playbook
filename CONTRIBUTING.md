# Contributing

Thanks for helping improve `devops-bash-playbook`.

## Development Standards

- Keep scripts Bash-only unless there is a strong operational reason not to.
- Use the shared helpers in `utils/` before introducing new one-off patterns.
- Add or update a paired Markdown file for every `.sh` file.
- Prefer idempotent operations and dry-run support for destructive workflows.
- Never commit secrets, tokens, or machine-specific credentials.

## Pull Request Checklist

- [ ] Script includes `#!/usr/bin/env bash`
- [ ] Script enables `set -euo pipefail`
- [ ] Logging and error handling are present
- [ ] `shellcheck` passes
- [ ] `bash -n` passes
- [ ] Documentation covers usage, outputs, and failure scenarios

## Local Validation

```bash
make lint
make validate
make docs-check
```

## Review Expectations

Maintainers review for:

- Safety of operational defaults
- Clear failure handling
- Reusability across teams and environments
- Alignment with the repository structure and style
