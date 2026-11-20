# Plan: [project name]

Read only the section of the current task. One section is one session; if it turns out bigger, split it (M2a, M2b) instead of stretching the session. Every section says how it is proven ("Done when"), so /start can quote it and /wrap can run it. A section whose heading carries an IF marker is optional: delete it if the condition doesn't hold.

## M0 Skeleton
- Repo structure, dependency file, `.env.example`, `.gitignore`, PROGRESS.md from its template, LICENSE ([MIT | the event's, client's or employer's terms | none, private repo]).
- The smallest thing that runs end to end and shows one real result: [e.g. a page showing one number from the data | firmware printing one sensor reading | a scene where the player moves].
- [IF deployed] Deployed and reachable on a phone.
- [IF competition] Check that "First question" in AGENTS.md is filled. If it isn't, ask me before building.
- [IF competition] Find the official evaluator or benchmark and run the supplied baseline. Put the command and the baseline's score in AGENTS.md "Official score". List what it scores (each task, label family or action) and mark which ones the plan answers; a gap gets a check in the plan or a line in "Not doing". If there is none, tell me, and propose a held-out split and a metric.
- [IF competition] Load the full data set once. Count the rows in every table its documentation describes and write the counts in PROGRESS.md; an empty table is compared against the original archive before anything is built on it. If something can't be loaded, tell me why.
- **Done when:** `[the Check command]` passes and [what I see when I run it].
- [IF competition] Also done when: AGENTS.md has the baseline's score, and PROGRESS.md has the row counts.

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
- [IF AI in the product] Read generated text for meaning as well as numbers: it must not claim more than the data shows, and it uses the app's own wording and units.
- **Done when:** `[command]` passes; by hand I check [what only a person can judge | nothing].

## First-question check [IF competition] (15 min, fresh session)
Read the results as the person in "For" would, and answer three things from them:
- The First question. If the answer is weak, the product changes, not the wording.
- The Title question: which built thing answers it? A page of text doesn't count.
- Each line of "Not doing" in AGENTS.md: does it still hold after what the sponsor and the data have said? Is a cheaper, software-only route written down as a limit instead of built?

If any answer is weak, tell me before going on.
- **Done when:** docs/history.md has the three answers and your verdict, and I approve it.

## Polish [IF competition]
- The demo moment, layout on the target screen, wording without jargon.
- Error states: [the ones you expect, e.g. missing data, no key, no connection].
- No function or variable names on screen, including loading messages.
- **Done when:** `[the Check command]` passes; by hand I check [the demo moment on the target screen].

## Review (fresh session)
Run `/judge`. It reports issues ranked by value per hour; I pick which ones get fixed, and each fix is its own `/start`.

## Submission dry run [IF competition] (before the last evening)
- Build the hand-in from the current commit. Unpack it in an empty folder and run it from its README alone: no setup beyond one command, where the data terms allow.
- Open the demo link signed out. It must work with no login and no setup.
- List every file in the hand-in that is a note and not product.
- Count every form field against its limit.
- **Done when:** docs/history.md lists each item as passed, or says what is missing.

## Freeze [IF competition]
After the judge pass, when the budget is used up, or when I say so. From then on, bug fixes only.
When the hand-in is ready: `/judge final` in a fresh session.
