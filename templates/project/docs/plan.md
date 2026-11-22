# Plan: [project name]

Read only the section of the current task. One section is one session; if it turns out bigger, split it (M2a, M2b) instead of stretching the session. Every section says how it is proven ("Done when"), so /start can quote it and /wrap can run it. A section whose heading carries an IF marker is optional: delete it if the condition doesn't hold.

## M0 Skeleton
- Repo structure, dependency file, `.env.example`, `.gitignore`, PROGRESS.md from its template, LICENSE ([MIT | the event's, client's or employer's terms | none, private repo]).
- The smallest thing that runs end to end and shows one real result: [e.g. a page showing one number from the data | firmware printing one sensor reading | a scene where the player moves].
- [IF deployed] Deployed and reachable on a phone.
- **Done when:** `[the Check command]` passes and [what I see when I run it].

## M1 Foundation
- [What everything else depends on: load and clean the data, plus its rules | drivers behind a hardware abstraction layer | core game loop and state].
- Tests on known cases, including the edge cases: [the ones you already know].
- [IF data] Drop physically implausible values and log how many. Before choosing the unit of analysis, count how many units have enough samples; if most don't, tell me.
- **Done when:** `[command, e.g. pytest tests/test_load.py]` passes.

## M2 Core feature
- [The core feature from the MVP], visible [on the main screen in plain language | where the user meets it].
- [IF data] If it ranks or shortlists: read the top results as the user would. They must make sense for that use, in that order.
- [IF data] If it exports: open the file where users will, with their locale settings (delimiter, decimal mark, encoding). If that can't be tested, list it as a limit.
- **Done when:** `[command]` passes; by hand I check [what only a person can judge | nothing].

## Model and its score [IF the project has a model]
- The model named in AGENTS.md, trained on [the training split] and never on the held-out one.
- Before naming the model after a signal (e.g. "pressure-to-weight"), read in the data documentation how that column is made.
- One line: [metric] [mine] against the baseline's [theirs], on [N] held-out cases, data labelled [real | simulated | synthetic]. Where no baseline is supplied, use the fairest simple one: the obvious columns a judge would try first, together, not one column alone. Say what the gain comes from.
- What it can't show, in one or two lines, for the limits section.
- **Done when:** `[the evaluator command]` prints the score.

## M3 [Next section, same shape: what it adds, then "Done when"]
- [What it adds.]
- [IF generated text in the product] Read generated text for meaning as well as numbers: it must not claim more than the data shows, and it uses the app's own wording and units.
- **Done when:** `[command]` passes; by hand I check [what only a person can judge | nothing].

## Review (fresh session)
Run `/judge`. It reports issues ranked by how much each would change the result, with the hours beside them; I pick which ones get fixed, and each fix is its own `/start`.
