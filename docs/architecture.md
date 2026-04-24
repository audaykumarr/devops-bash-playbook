# Repository Architecture

The repository is intentionally layered so operational scripts stay simple while shared logic remains centralized.

```mermaid
flowchart TD
    Templates["templates/*.sh"] --> TopicScripts["topic folders"]
    Utils["utils/*.sh"] --> TopicScripts
    TopicScripts --> Projects["projects/*"]
    TopicScripts --> Docs["paired .md files"]
    Projects --> Docs
    Docs --> Contributors["contributors and operators"]
    TopicScripts --> Workflow["GitHub Actions validation"]
```

Key design decisions:

- Shared utilities handle logging, validation, and retry semantics.
- Topic folders model operational domains instead of syntax levels.
- Projects show how individual scripts compose into larger delivery systems.
- Documentation is kept close to each script to reduce drift.
