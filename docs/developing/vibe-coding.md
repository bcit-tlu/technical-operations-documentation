---
tags:
    - develop
---
# AI coding (vibe coding)

Using AI as a co-developer usually improves your coding experience: tasks are completed faster, code is well-implemented and less prone to bugs, and tests creation/execution is much easier.

Generate AI provider API keys and add them to your IDE.

## Project


Thoroughly scan the GitHub action workflows, Helm charts, release-please config files, and supporting container files (.gitignore, .envrc, Makefile, Docker-related files, etc...) in these projects:
bcit-tlu/conversion-guide
bcit-tlu/course-workload-estimator
bcit-tlu/hriv
bcit-tlu/open-data
bcit-tlu/qcon-guide
bcit-tlu/sugar-suite
The patterns in these files are OPERATION_PATTERNS. Standardize these OPERATION_PATTERNS without breaking app or deployment functionality (both "latest" and "stable" environment overlays are now operational), remove dead/unused files, simplify comments (reduce verbosity while retaining key meanings), and ensure AI agent-oriented instructions related to these OPERATION_PATTERNS are summarized in an AGENTS.md file within each repo. The goal of this work is to generate a more up-to-date overview of common operating patterns so that they can be captured and used to update Devin playbook https://app.devin.ai/org/bcit-tlu/settings/playbooks/2fb97fc38d25442d8f7fe6447b30623a.
