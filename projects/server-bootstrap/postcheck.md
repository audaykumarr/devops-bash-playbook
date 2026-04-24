# `postcheck.sh`

        ## Problem Statement
        Bootstrap jobs are more trustworthy when they finish with explicit validation. This script checks the most important post-provisioning assumptions before a host is handed off.

        ## When To Use It
        - You want a fast smoke test after running `bootstrap.sh`.
- A pipeline needs to verify that a new host meets its baseline requirements.

        ## Prerequisites
        - Bash 4+
- The host already ran the bootstrap project script

        ## How It Works
        - Validates that the deploy user exists.
- Confirms the application directory is present.
- Checks that required commands are installed and executable.

        ## Example Usage
        ```bash
./projects/server-bootstrap/postcheck.sh --user deploy --app-dir /srv/apps --required-commands curl,jq,git
```

        ## Expected Output
        - A single success log when all checks pass.
- A nonzero exit if any baseline requirement is missing.

        ## Failure Scenarios
        - The bootstrap step partially failed and left the host inconsistent.
- A package was installed but not on the default PATH for the current user.
