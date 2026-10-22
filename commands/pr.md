---
description: Push the current branch and open a GitHub PR via gh
---
Current branch and state:

!`git branch --show-current && git status --short`

Commits not yet on the default branch:

!`git log --oneline @{upstream}..HEAD 2>/dev/null || git log --oneline -10`

Push the current branch with `git push -u origin HEAD`. Then open a pull request
with `gh pr create`. Derive the title from the commit history (imperative, no
trailing period) and write a concise body: what changed and why, as bullet
points. If a PR already exists for this branch, run `gh pr view --web` instead
of creating a duplicate. Report the PR URL.

Extra instructions: $ARGUMENTS
