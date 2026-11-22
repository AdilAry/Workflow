# The Short-Loop Workflow

How I work with a coding agent: short sessions, with files carrying the memory between them. Everything it needs is in `templates/`, next to this guide.

As of November 2026. The agent is Claude Code. The files are plain Markdown, so another agent can use them later: pi is planned for when I can host my own models (§6).

---

## 1. The idea

A session gets worse as its context fills up (context rot). So each session does one task and ends, and the next one starts clean and reads what it needs from files.

That only works if the files stay small. If they grow, every new session starts halfway into the dumb zone. That's what happened in the LoadLedger hackathon: by the end, CLAUDE.md and PROGRESS.md held the whole project history, and PROGRESS.md contradicted itself ("next: the video" after the video was done).

The fix is to split files by **how often they are read**:

| File | Holds | Loaded | Size | Edited by |
|---|---|---|---|---|
| User-level file (`~/.claude/CLAUDE.md`) | About me, my machines, rules for every project | Every session, every project | ~50 lines | Me, once |
| `AGENTS.md` (project) | Facts about this project, Check, Done gate, read-when pointers | Every session in this project | under ~120 lines | The agent at setup, from my answers (`/idea`); later only when I ask |
| `PROGRESS.md` | Current state only | Start of every session | under ~60 lines | Agent, via `/wrap` |
| `docs/plan.md` | What each task must deliver, and its "Done when" | At a task's start, its section only | Any | The agent at setup, from my answers (`/idea`) |
| `docs/history.md` | Finished tasks, judge passes, review rounds | Only when asked | Any (append only) | Agent |
| `docs/decisions.md` | Decisions with reasons and rejected options | When a decision is questioned | Any | Agent |
| `docs/data.md` (data projects) | Data rules: units, joins, timing, thresholds, once AGENTS.md's 5 lines are not enough | Before changing data code | As needed | Agent, from my rules |
| `docs/notes/` | Short summaries of long sources (specs, datasheets) | When a task needs one | Short each | Agent |
| Commands `/idea`, `/start`, `/wrap`, `/judge` | The session steps | When I type them | Short | Installed once per machine |

Sizes are rough guides. To see the real cost, look at the context use at the start of a session (§6).

**Five rules that keep the files small:**
1. **PROGRESS.md is a snapshot, not a log.** `/wrap` rewrites "Now" and "Next" every session.
2. **Delete, don't strike through.** Once something is resolved, it leaves PROGRESS.md; history.md keeps the record.
3. **Point, don't paste.** Long material lives in `docs/`, and AGENTS.md says when to read it.
4. **One fact, one place.** If AGENTS.md and PROGRESS.md both say it, one of them will go stale.
5. **Rules for every project go in the user-level file once**, not in each project's AGENTS.md.

---

## 2. Markers in the templates

| Marker | Meaning | Example |
|---|---|---|
| `[text]` | Fill in: replace the brackets and everything inside | `[one line]` → `A waste-cost checker for compactor customers` |
| `[value]` | Suggested default: keep or change it, then remove the brackets | `[16]` → `16` |
| `[a \| b \| c]` | Choose one; delete the rest | `[local only \| where]` → `local only` |
| `[IF condition]` on a line | The line applies only if the condition holds. If it does, delete the marker; if not, delete the line | `[IF deployed] Deployed and reachable on a phone` |
| `[IF condition]` in a heading | The same for the **whole section** under that heading | `## Data [IF the project uses data]` |

The optional sections are how one template serves different kinds of project. A plain project deletes `Problem` and `Data` from AGENTS.md and is left with about 50 lines. A data app keeps `Data`. A competition gets its own section from the Pitch_WF kit (§8).

The templates contain no other square brackets (no Markdown links or checkboxes). So any `[` left in AGENTS.md or docs/plan.md means something is unfinished. `/idea` runs this check itself; after an edit by hand, run it yourself:

```powershell
Select-String -Pattern '\[' -Path AGENTS.md, docs\plan.md
```
Bash: `grep -n '\[' AGENTS.md docs/plan.md`

In the files the agent maintains (PROGRESS.md, history.md, decisions.md), the brackets only show the format; the agent fills them.

---

## 3. Setup

### Once per machine

This makes `/idea`, `/start`, `/wrap` and `/judge` exist in every project, and installs the user-level file if there is none yet. Keep this folder in one fixed place: on Linux the commands are links into it.

**Linux and macOS, and Windows in Git Bash** (it comes with Git for Windows, which Claude Code needs):
```bash
bash install.sh
```
On Linux the commands are linked, so later a `git pull` (or an edit) in this folder updates them with nothing to re-run; if a harness doesn't show linked commands, use `bash install.sh --copy`. On Windows links don't work, so it copies them: run it again after every `git pull`. Type `/` in a new session to see that they are offered.

It also saves this folder as `WORKFLOW_DIR`, for kits (§8): in `~/.bashrc`, and on Windows as a user variable too, which PowerShell reads. For Claude Code it creates `~/.claude/settings.json` with medium as the default effort (`/start` and `/judge` raise it to high for their own turn, §4), but only if there is none. An existing one is never edited, because it may hold your permissions and hooks: the script prints the line to add instead.

Then open the user-level file once and fill its one bracket.

### Per project

In a terminal (Windows: Git Bash), from this folder:
```bash
bash new-project.sh <name>
```
It creates `~/projects/<name>` (Windows: `%USERPROFILE%\projects\<name>`) from `templates/project/`, puts the name in and makes the first commit. It refuses if git doesn't know your name and email yet, and says how to set them. A second argument picks another parent folder.

Then, on either machine, start the agent in the project:
1. `/idea` followed by the idea in a few sentences. The agent asks one question at a time, top down (what and why, then how, then in what order), each with a suggested answer. Then it fills in AGENTS.md and docs/plan.md, deletes the sections and docs that don't apply, and runs the bracket check.
2. Read both files and correct them until they say what you want. Then `/wrap`, and clear.
3. `/start M0`.

A kit's project starts from the kit's own steps instead (Embed_WF and Gamedev_WF have `/define`).

**Don't create a project inside another project, or inside this folder.** Agents load instruction files from every parent folder as well (pi walks up to the filesystem root, and Claude Code does the same for CLAUDE.md), so the inner project would silently get the outer one's instructions in every session. `new-project.sh` refuses when it sees that.

**For an existing codebase** there is no M0: copy only AGENTS.md, PROGRESS.md and `docs/history.md`, `docs/decisions.md`; write the real Check command; and start with `/start <the bug or feature>`.

---

## 4. A session

**Start:** `/start M2` (or any task, e.g. `/start fix the export`; with nothing, it takes "Next" from PROGRESS.md). The agent pulls, reads PROGRESS.md and the task's section of plan.md, and proposes a plan of at most 5 bullets ending in **done when:** the exact command that will prove it. For a task with no code (docs, research, a decision), "done when" is a file that must exist, what it must say, and my approval; the agent doesn't invent a check. Correct the plan or OK it; nothing changes before my OK. *(Gate 1.)* The plan is made at high effort (`effort: high` in the command); the work after my OK runs at the session's own effort, and so do `/wrap` and `/idea`. `/judge` reviews at high effort too.

If the last session left something "awaiting my check", `/start` asks about that first.

**After my OK** the agent works the plan and may loop on its own (run, read the failure, fix) until "done when" passes, or until one of the stop rules in `/start` step 7 applies (`templates/commands/start.md`). Then it tells me what to check and to type `/wrap`.

**End:** `/wrap`. It runs Check and "done when", rewrites PROGRESS.md, commits, and tells me which files changed, what to run, the output to expect and what to check by hand. Then I check it and clear the session. *(Gate 2.)*

**Finished means checked.** If the task has something only I can check (a screen, a feel, a real device), `/wrap` does not write its history entry or add it to "Done". It goes under "Waiting on me" as "awaiting my check", and the next `/start` asks me and records the answer. A task with no such check is finished when "done when" passes.

Ending in the middle of a task is fine: `/wrap` records exactly where it stopped.

**Habits that keep context clean:**
- **Wrong path? Go back** to before the attempt and re-prompt with what you learned. Correcting ("no, try B") leaves the failed attempt in context, where it keeps steering the agent.
- **Watch the context.** The stop rules in `/start` step 7 are what end a session that goes wrong. As a backstop: past about 200k tokens (`/context`), finish the current step and wrap. A one-task session used about 60k (measured, November 2026).
- **Big reading** (a spec, a datasheet, another codebase): give it its own session, or a subagent, that only writes a summary into `docs/notes/`. Later sessions read the note, not the source.
- **Look, don't dump.** One huge log in the context costs more than ten small runs. Long output goes to `out/`, and only a summary into the conversation.
- **Same mistake twice:** stop. `/wrap`, clear, and start fresh with what you learned in the first prompt.

---

## 5. Reviews with fresh eyes

The judge pass (`/judge`) and the final review (`/judge final`) each run in a **new session**. A reviewer that watched the work being built ends up grading its own work.

For a second opinion from a different model, the Codex review plugin runs inside Claude Code on your OpenAI budget.

---

## 6. Claude Code now, pi later

Claude Code is the agent. pi is for the future, once I can host my own models: Claude plans don't cover it, so today it would run on OpenAI or an API key. Nothing here needs pi, and nothing needs changing to add it later. `install.sh` already installs for pi if it finds pi on the machine. This table is what will differ when that day comes.

| | Claude Code | pi (later) |
|---|---|---|
| Project instructions | AGENTS.md, read by itself from v2.1.277, as long as there is no `CLAUDE.md`, `CLAUDE.local.md` or `.claude/CLAUDE.md` in the project or a parent folder (`~/.claude/CLAUDE.md` doesn't count) | AGENTS.md. In each folder pi loads one file: `AGENTS.override.md`, else `AGENTS.md`, else `CLAUDE.md` |
| User-level file | `~/.claude/CLAUDE.md` | `~/.pi/agent/AGENTS.md` (pi does not read `~/.claude/`) |
| Commands | `~/.claude/commands/*.md` | `~/.pi/agent/prompts/*.md` (pi does not read `.claude/commands/`) |
| New task, new session | `/clear` | `/new` |
| Go back to before a wrong attempt | Esc Esc (rewind) | `/tree`, pick the earlier point |
| How full is the context | `/context` | the footer, `/session` |
| Side question that isn't added to the conversation | `/btw` | none; ask in another session |
| Asks before running a command | yes | **never**: run it in a container or a separate user account |
| Paid by | a Claude plan | OpenAI login, Copilot or an API key. Claude plan limits don't cover pi |

So a project needs no `CLAUDE.md`. If it has one (a kit's template, or a version older than v2.1.277), Claude Code reads that file instead, so it must hold the line `@AGENTS.md`. The "Project instructions" setting in `/config` stays at its default (CLAUDE.md or AGENTS.md). To see what a session really loaded, run `/context all` in Claude Code and look under "Memory files".

Because the memory is in the files, switching agent later needs no migration: the next session just starts in the other agent.

---

## 7. When things go wrong

| Symptom | Fix |
|---|---|
| `/context` at the start of a session shows Memory files above ~5k tokens | Trim AGENTS.md and PROGRESS.md; move detail to `docs/`. Check that no parent folder has its own AGENTS.md or CLAUDE.md. |
| The agent works from stale information | PROGRESS.md contradicts itself: rewrite "Now" and "Next", delete resolved items. |
| Auto-compact fired | Finish the current step, `/wrap`, start fresh. |
| A task doesn't fit in one session | Split it in plan.md (M2a, M2b). |
| The agent hits the Run limit | The task is too big or its "Done when" too far away. Split it, or wrap and restart with what the runs showed. If healthy sessions hit it, raise the number in AGENTS.md. |
| The plan at Gate 1 keeps being wrong | The plan section is too vague. Put the edge cases and the "Done when" there, not in chat. |
| The same mistake keeps coming back | First make Check catch it: a lint rule, a test or a type check. That costs no context and always holds. Only if that can't be done, add one line to AGENTS.md (or the user-level file if it happens in every project). Remove rules again once models stop needing them. |
| A lesson from the last project wasn't applied | It was a reminder. Put it into a step that already exists: a "Done when" in docs/plan.md, or a question in `/judge`. |
| The agent keeps asking what to do next | "Next" in PROGRESS.md isn't concrete enough to start from. |
| "Waiting on me" piles up | You're not checking. Nothing there counts as done; check before starting more. |
| `/start` isn't offered | The commands aren't installed for this agent on this machine (§3). |

---

## 8. Adapting to project types

| Project | Check command | M1 foundation | Notes |
|---|---|---|---|
| Data app (Python) | `pytest` | Load and clean data, rules, tests | Keep the `Data` section; its rules move to `docs/data.md` when they outgrow 5 lines |
| Competition or client demo | as above | as above | The Pitch_WF kit adds the `Competition` section (budget and time table, official score, first-question check, submission dry run, freeze, AI log) and the presentation materials: deck, video, write-up. |
| Embedded | Host-side tests (e.g. `pio test -e native`) plus the build | Hardware abstraction layer, drivers, logic tested on the PC | Pin map and errata go in `docs/hardware.md`, with a read-when row. For ESP32 with a test bench, the Embed_WF kit builds on this workflow. |
| Game (Godot) | Headless tests (GUT or gdUnit4) | Core loop and game state | Game feel is yours to tune: expose values as exported variables, and expect "awaiting my check" on most tasks. For Godot games, the Gamedev_WF kit builds on this workflow; its simulation tools fit strategy and sim games best. |
| Existing codebase | Its own test command | none | No M0; see §3 |
| Writing, notes, comic scripts | None, or the site build (e.g. `hugo`) | None | Every task is a no-code task: its "done when" is a file, what it must say, and my approval, so each one ends "awaiting my check" (§4). Drawing and art stay outside the workflow. |

**If a project should teach me something** (the old "learn" mode): say so in the task. `/start write the parser, but leave the tokenizer to me` gives a plan whose "done when" is "the scaffold builds and only the tokenizer tests fail". The loop has an end again, which a project-wide learn mode did not give it.

### Building a kit on this workflow

A kit (Embed_WF or Gamedev_WF, for instance) adds a project template and its own commands for one kind of project. It should work with whichever version of this workflow is installed. To make that possible, it relies only on the list below and never copies or restates anything else from this folder. If a kit needs a word that isn't listed, add the word here first, and change the date. Change the date too when the core drops or moves something a kit used, even if no listed word changes.

**Contract of 22 November 2026.** A kit's README names the date it was written against.

- **Commands:** `/start <task>`, `/wrap <note>`, `/judge [final]`.
- **AGENTS.md fields the commands read:** Check, Done gate, Run limit, Push, "At /start also", "At /wrap also", "Read only when needed", "Judged on", "At /judge also" and "At /judge also (final)" (all three read by `/judge`). The two "also" fields of `/start` and `/wrap` are where a kit adds steps to the bookkeeping at the start and end of a session; "At /judge also" is where it adds review steps, which `/judge` does first, and "At /judge also (final)" holds those that run only in the final review. A project's AGENTS.md may list an "also" field in more than one section; the commands do them all. Everything else in a kit's AGENTS.md is project facts that the agent follows while it works, such as the order in which test tiers run. The kit's AGENTS.md doesn't repeat the loop or its stop rules; those live in `/start`.
- **PROGRESS.md sections:** Now, Next, Broken, Waiting on me, Done, How to run. An item only I can check waits there as "awaiting my check". "How to run" says first what a machine needs (tools and versions, hardware, accounts), then the commands; `/judge` treats that setup as expected.
- **docs/:** `history.md` and `decisions.md`, in the formats of `templates/project/docs/`.
- **The plan:** any file that "Read only when needed" points to. Each task in it has a "Done when", or the Done gate applies. If the plan has checkboxes, `/start` and `/wrap` tick them. A kit that marks finished tasks some other way (a status column, say) does it in its "At /start also" and "At /wrap also" steps.
- **Where the workflow lives:** `WORKFLOW_DIR`, which §3 sets once per machine. A kit reads it to find this folder, for instance to copy `templates/project/` files, and stops with a clear message if it isn't set. It never guesses a path.
- **Git commands the workflow runs:** `git pull` (`/start`); `git status`, `git add`, `git commit`, `git show --stat`, and `git push` only as Push allows (`/wrap`); `git add` and `git commit` (`/judge`). A kit that sets up permissions, such as a Claude Code allowlist, allows at least these plus its own Check and Done gate commands, so a session never waits on a prompt the workflow causes. It may add other read-only commands the agent uses while working, such as `git diff` and `git log`. When a command changes the git commands it runs, this line and the date change with it.
- **Not in the core:** anything only competitions use (budget, official score, hand-in, first-question check, submission dry run, freeze, AI log). A kit that needs it brings it in its own template, with its review steps under "At /judge also".
- **Installing a kit's commands:** `bash "$WORKFLOW_DIR/install.sh" <kit commands folder>` (Windows: in Git Bash). On Windows a kit may instead copy its commands into `%USERPROFILE%\.claude\commands` itself, for instance with PowerShell's `Copy-Item`. Kit commands use the same file format as `templates/commands/`.

---

## 9. What changed, and why

### From the LoadLedger version

| Before | Now |
|---|---|
| "About me", secrets and working rules repeated in every project's CLAUDE.md | Once, in the user-level file |
| Full milestone instructions in CLAUDE.md, loaded every session | Details in docs/plan.md, read one section at a time |
| Judge-pass and final-review instructions in CLAUDE.md | The `/judge` command, loaded only when typed |
| End-of-session steps written out in the rules | The `/wrap` command, the same every time |
| PROGRESS.md held milestone write-ups, judge passes, review rounds and the AI log | PROGRESS.md: current state only. The rest goes to history.md, decisions.md and ai_log.md |
| Resolved items struck through | Deleted |
| Data rules (as-of times, joins, rounding) in CLAUDE.md | `docs/data.md`, read before data code changes |

### In this version (November 2026)

| Before | Now | Why |
|---|---|---|
| ship / learn modes | Gone | Learn mode left core logic as `TODO(human)`, so "done when" could never pass and the loop had no end. Teaching is now a per-task request (§8). |
| `CLAUDE.md` was the instruction file; commands in each project's `.claude/commands/` | `AGENTS.md` plus a one-line `CLAUDE.md`; commands installed once per machine | pi would have read the project's CLAUDE.md, but not the user-level file or the commands. AGENTS.md is also the one name every agent reads. One installed copy of the commands means an update is one `git pull`, not an edit in every repo. |
| One template shaped by a hackathon; other projects edited hackathon fields out line by line | The same single template, with `Problem`, `Competition` and `Data` as whole optional sections | A plain project deletes three sections instead of hunting for fields. The competition section carries its own start and wrap steps, so time tracking and the AI log travel with it. |
| Nothing stopped the agent from editing a test until it passed | The loop stops when passing would mean changing or deleting an existing test the plan doesn't name, and `/wrap` lists changed test files on their own | The easiest way to turn a failing test green is to change the test. A test changes only when the plan says the behaviour it checks changes, or after I agree it was wrong. |
| The loop could run until the context was full | Run limit: 20 test or build runs per session, passed or failed, set per project | A session now has a countable end. Every run counts, not only failures of "done when": otherwise the agent could loop on other commands forever, and a first run that is meant to fail would be hard to tell from one that isn't. |
| `/wrap` marked a task done when its command passed | A task with a check only I can do stays "awaiting my check" until I confirm it | The command passing is the agent's evidence. Finished is my call. |
| "Done when" assumed a command | No-code tasks name a file, what it must say, and my approval | Otherwise the agent invents a check to satisfy the rule. |
| Time logged in every project, with a Time table in every PROGRESS.md | Only with the `Competition` section, which creates the table when it first logs a time | Nothing used it outside a budgeted event, and a file the agent maintains should have nothing for me to delete. |
| history.md entries carried "time spent" | Only with the `Competition` section | Same reason. |

### Since then (19–20 November 2026)

| Before | Now | Why |
|---|---|---|
| `/wrap` "ticked" a finished task where the plan lives | The record of finished is the history.md entry plus the "Done" line. Plans with checkboxes still get ticked. A kit that marks finished tasks another way does it in its "also" steps | The generic plan has no checkboxes, so every agent invented its own tick. A tick would also record the same fact a third time. |
| PROGRESS.md was said to hold decisions and dead ends (efficient-ai-tools.md) | efficient-ai-tools.md points to §1 instead of describing the files. A dead end goes in "Now" while it matters to the task, and in decisions.md under "Rejected" once settled | One fact, one place: the second description had already drifted. |
| pi described as the second agent | Claude Code is the agent; pi is for later, with self-hosted models (§6) | Claude plans don't cover pi, and the laptops can't host models big enough for agent loops yet. |
| Windows per-project setup was one `Copy-Item` | Seven PowerShell steps that do what `new-project.sh` does (§3) | Windows is the main machine. The old line skipped the name, the notes folder, the parent-folder check and the first commit. |
| A kit (Embed_WF) carried its own copy of this workflow | Kits rely only on the list in §8, "Building a kit on this workflow" | The copy had already fallen behind this version. |
| Each kit saved the workflow's location its own way, or guessed it | `install.sh` (Windows: one line in §3) saves `WORKFLOW_DIR`; §8 names it | Both kits need it, one of them after install too. One variable in one place instead of one per kit. |
| `install.sh` saved `WORKFLOW_DIR` only after finding an agent | It saves it first, then looks for an agent (20 Nov) | On a fresh machine the kit's setup installs the agent, so it needs `WORKFLOW_DIR` before any agent exists. Otherwise setup ran twice. |
| Nothing listed the git commands the workflow runs | §8 lists them; contract of 20 November 2026 | Gamedev_WF's allowlist missed `git pull` (`/start`) and `git show` (`/wrap`), so every session waited on a prompt. Each kit was guessing from the command files. The list is a minimum: read-only helpers such as `git diff` and `git log` may be added (a clarification, so the contract date stays). |
| The §8 list left out "Judged on" and said every task has a "Done when" | "Judged on" is listed; a task without "Done when" falls back to the Done gate, as `/start` already did. The list carries a date | Both kits rely on these. The date lets a kit say which version of the list it was written against. |
| `templates/project/.gitignore` ignored `secrets.h` | Removed | It's an embedded detail; Embed_WF's own template already ignores it. |

### From the Since AI 2026 findings (21 November 2026)

No new step in a session: the checks that already existed ask more. The one new plan section is the submission dry run.

| Before | Now | Why |
|---|---|---|
| `/judge` ranked issues by value per hour | By how much each would change the result, with the hours beside it | Value per hour favoured a 20-minute paragraph over the one large gap. At Since AI the winning route was written up as a limit three times instead of built. |
| `/judge` scored against the criteria only | With a `Competition` section it also starts from the hand-in with no setup, asks what the winning entry would show, re-reads "Not doing" and lists headline sentences that argue against the project | The judge pass found the weak spot but never looked at the entry against a competing one. |
| A kit could add steps to `/start` and `/wrap` only | "At /judge also" (§8): a kit adds review steps too | The presentation kit's skim test and deck and video checks belong to the kit, not to every project. |
| The first-question check asked one question | Three: the first question, the title question, and whether each line of "Not doing" still holds | The challenge's title was answered by a concept page, and a "Not doing" line written on day one was never reopened. |
| "AI in the product: rules and real data decide; AI only explains" | A `Model` line (at a competition the default is to build it) and a separate line for generated text | The old line read as a rule against trained models. The top entries each had one, with a measured score. |
| No official score | An `Official score` line; M0 runs the evaluator's baseline, lists what it scores and counts the rows of every table | The package's evaluator was never run, and the extracted data had an empty table nobody noticed. |
| Demo: a hosted link plus a ZIP that needed data copied in | `Demo access`: no setup for the judge | The hosted demo was never opened, and every setup step loses a hurried judge. |
| The hand-in was assembled on the last night | A submission dry run before the last evening | The ZIP was rebuilt several times, and personal notes were found in it at 01:57. |
| Files handed to a chat could be copied into the repo | User-level rule: a file from outside the repo stays outside | Prep notes with informal remarks ended up in the production repo. |
| Lessons kept in a "Remember" list | Put into a step that already exists (§7) | A lesson from the dry run sat in that list and was not applied. |
| `/judge` counted every setup step as an issue, in every project | Only with "Demo access" does it start from the hand-in alone. Otherwise the setup that PROGRESS.md "How to run" says a machine needs is expected, and only steps beyond it, or steps that fail as written, are issues | Both kits found that every pass would have flagged the dev box, the boards or the Godot install. One rule in `/judge` instead of a workaround in each kit. |

### From the workflow review (21–22 November 2026)

| Before | Now | Why |
|---|---|---|
| The template's Done gate said "the task's Done when passes", and `/start` said "Done when, otherwise the Done gate" | The Done gate is the default proof for a task whose plan section has no "Done when"; a "Done when" replaces it | The two definitions pointed at each other. Same field, same §8 contract; kits that set their own Done gate already use it this way. |
| The stop rules were written out in both `/start` and §4 | Only in `/start` step 7; §4 points there | One fact, one place. §4 had already lost detail that `/start` has. |
| Writing projects "don't fit" | They fit as no-code tasks, each ending "awaiting my check" (§8) | `/start` already handles tasks without code. |
| Every append to docs/history.md read the whole file first (Claude Code's Edit needs a read) | `/start`, `/wrap` and `/judge` read only its end (`tail -n 15`); `/judge final` finds the last judge pass with `grep` and reads only that entry | The file only grows, so the cost of each append grew with the project. `tail` and `grep` need no permission prompt, and `tail` counts as the read Edit needs. Appending with `cat >>` would have prompted on every wrap. |
| The core template and `/judge` carried a `Competition` section, four competition plan sections, three competition review steps and `docs/ai_log.md` | All of it moves to the Pitch_WF kit; the §8 list says so, and its date is 22 November 2026. The date rule now also covers material that leaves the core | 28 of the 93 brackets, and three `/judge` steps, served only competitions, and Pitch_WF already adds everything else a competition needs. Embed_WF and Gamedev_WF use none of it, so their 21 November date still holds. |
| Nothing said which model or effort to use; I set Opus high for planning and judging, medium otherwise, by hand | `effort: high` in `/start` and `/judge`. It lasts for the turn the command runs: the plan at Gate 1, and the review. Medium is the default: `install.sh` creates `~/.claude/settings.json` with it, only if there is no such file | Thinking and output are what effort changes, and output costs most. On Opus 5.5 with a subscription, changing effort keeps the prompt cache; a model switch (such as `opusplan`) starts a fresh one. A turn after `/judge` asks me something runs at the session's effort. An existing settings file is never edited (it may hold permissions and hooks, and Claude Code writes to it), and `CLAUDE_CODE_EFFORT_LEVEL` would outrank the commands' `effort: high`. |
| Windows setup was 5 PowerShell install lines and 7 per-project steps that restated the two scripts | `install.sh` and `new-project.sh` run in Git Bash. There `install.sh` copies instead of linking and also saves `WORKFLOW_DIR` as a Windows user variable (§3) | One way on both machines, and no second copy of each script to keep in step. Git Bash comes with Git for Windows, which Claude Code needs. `ln -s` in Git Bash silently makes a copy, so link mode would have said "linked" wrongly. A kit may still copy its commands with PowerShell (§8), so the contract date stays. |
| 17 core files, against a limit of 15 | 14: `efficient-ai-tools.md` left the repo, `templates/project/docs/data.md` and the one-line `templates/project/CLAUDE.md` are gone | The tool notes are mine, and no command, template or kit read them. `data.md` repeated the Data section's sources and licences; its headings now sit in that section, and the agent creates the file once the rules outgrow 5 lines. Claude Code reads AGENTS.md by itself from v2.1.277 when there is no CLAUDE.md. No kit used these files, so the contract date stays. |
| I filled in about 50 brackets in AGENTS.md and plan.md (93 with every optional section kept), and the agent's questions were an optional step afterwards | `/idea`: the agent asks one question at a time, top down, each with a suggested answer, then fills both files and runs the bracket check; I approve them (§3) | Most of the setup effort was those two files. Answering a suggestion is faster than filling a field, and the agent deletes the sections that don't apply. It isn't called `/define`, because both kits have their own. |
| A mistake that kept coming back got a line in AGENTS.md (§7) | First a lint rule, test or type check inside Check; a line only if that can't be done | A line is loaded in every session and only asks; a check costs no context and always holds. From Matt Pocock's `retro` skill: "Default to building the check over writing the rule." |
| A vague plan section was found out at Gate 1, when I corrected the plan | `/start` step 4: if the section names no edge cases, or its "Done when" names no command or file, the agent asks me at most 3 questions, one at a time, each with a suggested answer; after my OK it writes the answers into the section | The questions come before the plan instead of corrections after it, and the answers stay in plan.md for later sessions. Capped and conditional, unlike the open-ended grill-me skill, so a clear section costs nothing; a task with no plan section skips it. Writing waits for my OK, as step 6 requires. |
| Nothing in the plan said which steps can't be undone | `/start`'s plan names every step git can't undo (deploy, push, send, flash fuses, delete or migrate data outside git), or "none"; each waits for my word | Everything committed can be reverted; these can't. Gate 1 is the last point before they happen, so that is where they're named, not in the `/wrap` report. |
| Wrap at about 40% context; a session starting at 15%+ needs trimming | The stop rules end a session that goes wrong; past about 200k tokens, wrap as a backstop. Trim when Memory files at the start pass ~5k tokens | On a 1M window the percentages meant 400k and 150k: a one-task session used about 60k, so neither ever fired. No study measures where an agent session on today's models starts to decay, and measuring it myself would cost several usage windows. 200k is a judgement, not a measurement: well past a normal session and under where most studies see trouble. The start rule now watches only what the workflow controls; Claude Code's own ~34k is fixed. |
| "A named test covers the change" said nothing about what the test checks | `/judge` step 3 reads some tests; one that only repeats the implementation is an issue | Such a test passes the Done gate and proves nothing. A question in an existing step, not a separate architecture-review session (§7: lessons go into steps that exist). |

Not changed on purpose: the split of files by read frequency, the five rules, the snapshot PROGRESS.md, the two gates, the fresh-session review, the bracket markers.
