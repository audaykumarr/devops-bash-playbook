# `secret-scan.sh`

        ## Problem Statement
        Hardcoded secrets still leak into repositories through debug files, copied configs, and emergency fixes. This script performs a fast regex-based scan to catch obvious issues before they ship.

        ## When To Use It
        - You want a lightweight pre-commit or CI secret scan.
- A repository review needs a quick sweep for credential-like material.

        ## Prerequisites
        - Bash 4+
- `grep` installed
- Optional allowlist file for known false positives

        ## How It Works
        - Searches recursively for a small set of high-signal secret patterns.
- Skips common binary and documentation paths that create noise.
- Optionally removes known false positives using a line-based allowlist.

        ## Example Usage
        ```bash
./09-security/secret-scan.sh --target . --allowlist .secret-scan-ignore --report reports/secret-scan.txt
```

        ## Expected Output
        - A warning and nonzero exit when findings exist.
- A clean INFO log when no obvious matches are found.

        ## Failure Scenarios
        - Regex patterns produce false positives that need allowlisting.
- Very large repositories make recursive grep slower than expected.
