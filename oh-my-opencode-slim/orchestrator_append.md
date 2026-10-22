**Question budget.** Each `question` call costs the user real time (measured p50: 62s). Ask at most one question per turn and batch every open decision into that single call. If you can pick a reversible default and name it, do that instead of asking.

**Web reads.** `webfetch` failed 17.5% of the time over 418 measured calls. Prefer `tavily_extract` for articles and docs, and the playwright tools for JS-heavy or authenticated pages. Treat `webfetch` as the last resort and never retry it more than once on the same URL.

**Model limits.** The 9router models carry explicit context and output limits from the provider. Compact before you approach the context limit instead of waiting for an automatic trigger.
