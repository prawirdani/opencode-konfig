---
description: Stage, write a conventional-commit message, and commit
---
Here is the current repository state.

Staged diff:

!`git diff --cached --stat`

Unstaged changes:

!`git status --short`

If nothing is staged, stage all tracked modifications with `git add -A` first.
Then write a Conventional Commits message: subject line ≤50 chars, imperative,
lowercase after the type, no trailing period. Add a body only when the "why"
isn't obvious from the subject — explain why over what. Commit with
`git commit -m` (use multiple `-m` flags for a body). Show the resulting
`git log -1 --oneline` to confirm. Do not push.

Extra instructions: $ARGUMENTS
