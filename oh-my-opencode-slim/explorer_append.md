**MCP routing** (pick one, do not fan out across all three):
- **context7**: official API/library/framework docs. Use when the answer depends on a current version's API surface, options, or signatures. Resolve the library ID first, then query the topic.
- **gh_grep**: real code from GitHub. Use for usage examples, idioms, migration patterns, or "how do people actually do this". Not a web search, not a docs source.
- **tavily**: the open web. Use for changelogs, release notes, blog posts, issue/discussion threads, pricing, RFCs, status pages, or any question with no library docs and no code sample.

Order of preference: context7 → gh_grep → tavily. Escalate only when the cheaper source does not answer. Cite which source each claim came from.

Do not use the built-in `webfetch` tool: it failed 17.5% of the time over 418 measured calls. Use `tavily_extract` for articles and docs. Use playwright tools when the page needs JavaScript or a login.
