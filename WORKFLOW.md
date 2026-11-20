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
| `AGENTS.md` (project) | Facts about this project, Check, Done gate, read-when pointers | Every session in this project | under ~120 lines | Me at setup; the agent only when I ask |
| `CLAUDE.md` (project) | One line, `@AGENTS.md` | By Claude Code, to find AGENTS.md | 1 line | Nobody |
| `PROGRESS.md` | Current state only | Start of every session | under ~60 lines | Agent, via `/wrap` |
| `docs/plan.md` | What each task must deliver, and its "Done when" | At a task's start, its section only | Any | Me at setup |
| `docs/history.md` | Finished tasks, judge passes, review rounds | Only when asked | Any (append only) | Agent |
| `docs/decisions.md` | Decisions with reasons and rejected options | When a decision is questioned | Any | Agent |
| `docs/data.md` (optional) | Data rules: units, joins, timing, thresholds | Before changing data code | As needed | Me, then the agent |
| `docs/ai_log.md` (optional) | AI tools used, for the README and disclosures | At the end | Any | Agent |
| `docs/notes/` | Short summaries of long sources (specs, datasheets) | When a task needs one | Short each | Agent |
| Commands `/start`, `/wrap`, `/judge` | The session steps | When I type them | Short | Installed once per machine |

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
| `[IF condition]` in a heading | The same for the **whole section** under that heading | `## Competition [IF someone else judges the result ...]` |

The optional sections are how one template serves different kinds of project. A plain project deletes `Problem`, `Competition` and `Data` from AGENTS.md and is left with about 50 lines. A hackathon keeps `Competition`. A data app keeps `Data`.

The templates contain no other square brackets (no Markdown links or checkboxes). So before the first session, any `[` left in a file you fill in means something is unfinished:

```powershell
Select-String -Pattern '\[' -Path AGENTS.md, docs\plan.md, docs\data.md
```
Bash: `grep -n '\[' AGENTS.md docs/plan.md docs/data.md`

In the files the agent maintains (PROGRESS.md, history.md, decisions.md, ai_log.md), the brackets only show the format; the agent fills them.

---

## 3. Setup

### Once per machine

This makes `/start`, `/wrap` and `/judge` exist in every project, and installs the user-level file if there is none yet. Keep this folder in one fixed place: on Linux the commands are links into it.

**Linux (and macOS):**
```bash
bash install.sh
```
The commands are linked, so later a `git pull` (or an edit) in this folder updates them with nothing to re-run. Type `/` in a new session to see that they are offered; if a harness doesn't show linked commands, use `bash install.sh --copy`. It also saves this folder as `WORKFLOW_DIR` in `~/.bashrc`, for kits (§8).

**Windows (PowerShell, Claude Code), from this folder:**
```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\commands" | Out-Null
```
```powershell
Copy-Item templates\commands\*.md "$env:USERPROFILE\.claude\commands\"
```
```powershell
if (-not (Test-Path "$env:USERPROFILE\.claude\CLAUDE.md")) { Copy-Item templates\user-level\AGENTS.md "$env:USERPROFILE\.claude\CLAUDE.md" }
```
```powershell
[Environment]::SetEnvironmentVariable("WORKFLOW_DIR", (Get-Location).Path, "User")
```
These are copies: repeat the second line when the commands change. The last line saves this folder as `WORKFLOW_DIR`, for kits (§8); new terminals see it. Run it again if the folder moves.

Then open the user-level file once and fill its one bracket.

### Per project

**Linux:** `bash new-project.sh <name>` creates `~/projects/<name>` from `templates/project/`, puts the name in and makes the first commit.

**Windows (PowerShell):** these steps do what `new-project.sh` does. Run them one at a time in a new terminal. In the first two lines, change only what is in quotes.

1. Set the name (lowercase letters, digits, `-` and `_`) and the workflow folder:
   ```powershell
   $name = "myproject"; $wf = "C:\path\to\this\folder"
   ```
2. Git must know who you are. Both lines must print something; if one doesn't, set it with `git config --global user.name "Your Name"` (and `user.email`):
   ```powershell
   git config user.name; git config user.email
   ```
3. Create the folder. This fails if it already exists, which is what you want:
   ```powershell
   New-Item -ItemType Directory "$env:USERPROFILE\projects\$name" | Out-Null; Set-Location "$env:USERPROFILE\projects\$name"
   ```
4. No parent folder may hold its own instruction file (see the warning below). This must print nothing:
   ```powershell
   $d = (Get-Item ..); while ($d) { 'AGENTS.override.md','AGENTS.md','CLAUDE.md' | % { Join-Path $d.FullName $_ } | ? { Test-Path $_ }; $d = $d.Parent }
   ```
   If it prints a file, go back to the parent folder, delete the new folder, and pick a parent outside that file's folder.
5. Copy the starter and add the notes folder:
   ```powershell
   Copy-Item -Recurse -Force "$wf\templates\project\*" .; New-Item -ItemType Directory -Force docs\notes | Out-Null
   ```
6. Put the name in. This writes UTF-8, so `·`, `–` and `→` survive in Windows PowerShell 5.1:
   ```powershell
   Get-ChildItem -Recurse -File -Filter *.md | % { $t = [IO.File]::ReadAllText($_.FullName); if ($t.Contains('[project name]')) { [IO.File]::WriteAllText($_.FullName, $t.Replace('[project name]', $name)) } }
   ```
7. Make the first commit:
   ```powershell
   git init -q -b main; git add -A; git commit -q -m "Start $name from the short-loop starter"
   ```

Then, on either machine:
1. Fill in AGENTS.md and docs/plan.md. Delete the `[IF ...]` sections that don't apply, and the docs that don't apply (`docs/data.md` unless it's a data project, `docs/ai_log.md` unless you must disclose AI use).
2. Run the bracket check above until it finds nothing.
3. Optional but cheap: in a first session, ask the agent to read AGENTS.md and question you about anything unclear. Fix AGENTS.md, then clear.
4. `/start M0`.

**Don't create a project inside another project, or inside this folder.** Agents load instruction files from every parent folder as well (pi walks up to the filesystem root, and Claude Code does the same for CLAUDE.md), so the inner project would silently get the outer one's instructions in every session. `new-project.sh` refuses when it sees that.

**For an existing codebase** there is no M0: copy only AGENTS.md, CLAUDE.md, PROGRESS.md and `docs/history.md`, `docs/decisions.md`; write the real Check command; and start with `/start <the bug or feature>`.

---

## 4. A session

**Start:** `/start M2` (or any task, e.g. `/start fix the export`; with nothing, it takes "Next" from PROGRESS.md). The agent pulls, reads PROGRESS.md and the task's section of plan.md, and proposes a plan of at most 5 bullets ending in **done when:** the exact command that will prove it. For a task with no code (docs, research, a decision), "done when" is a file that must exist, what it must say, and my approval; the agent doesn't invent a check. Correct the plan or OK it; nothing changes before my OK. *(Gate 1.)*

If the last session left something "awaiting my check", `/start` asks about that first.

**After my OK** the agent works the plan and may loop on its own (run, read the failure, fix) until "done when" passes. It stops and reports if:
- it needs to leave the plan;
- the same failure survives 3 different fixes;
- passing would mean changing or deleting an existing test that the plan doesn't name;
- it has made as many test or build runs as the project's Run limit (20 by default), counting every run, passed or failed;
- something needs my hands, or the plan is ambiguous or wrong.

Then it tells me what to check and to type `/wrap`.

**End:** `/wrap`. It runs Check and "done when", rewrites PROGRESS.md, commits, and tells me which files changed, what to run, the output to expect and what to check by hand. Then I check it and clear the session. *(Gate 2.)*

**Finished means checked.** If the task has something only I can check (a screen, a feel, a real device), `/wrap` does not write its history entry or add it to "Done". It goes under "Waiting on me" as "awaiting my check", and the next `/start` asks me and records the answer. A task with no such check is finished when "done when" passes.

Ending in the middle of a task is fine: `/wrap` records exactly where it stopped.

**Habits that keep context clean:**
- **Wrong path? Go back** to before the attempt and re-prompt with what you learned. Correcting ("no, try B") leaves the failed attempt in context, where it keeps steering the agent.
- **Watch the context.** Around 40% full, finish the current step and wrap.
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
| Project instructions | `CLAUDE.md`, which imports AGENTS.md. From v2.1.277 it also reads AGENTS.md by itself when there is no CLAUDE.md | AGENTS.md. In each folder pi loads one file: `AGENTS.override.md`, else `AGENTS.md`, else `CLAUDE.md` |
| User-level file | `~/.claude/CLAUDE.md` | `~/.pi/agent/AGENTS.md` (pi does not read `~/.claude/`) |
| Commands | `~/.claude/commands/*.md` | `~/.pi/agent/prompts/*.md` (pi does not read `.claude/commands/`) |
| New task, new session | `/clear` | `/new` |
| Go back to before a wrong attempt | Esc Esc (rewind) | `/tree`, pick the earlier point |
| How full is the context | `/context` | the footer, `/session` |
| Side question that isn't added to the conversation | `/btw` | none; ask in another session |
| Asks before running a command | yes | **never**: run it in a container or a separate user account |
| Paid by | a Claude plan | OpenAI login, Copilot or an API key. Claude plan limits don't cover pi |

The one-line `CLAUDE.md` is safe to keep on any version: Claude Code's docs say the import never makes it read AGENTS.md twice. To see what a session really loaded, run `/context all` in Claude Code and look under "Memory files".

Because the memory is in the files, switching agent later needs no migration: the next session just starts in the other agent.

---

## 7. When things go wrong

| Symptom | Fix |
|---|---|
| A session starts at 15%+ context | Trim AGENTS.md and PROGRESS.md; move detail to `docs/`. Check that no parent folder has its own AGENTS.md or CLAUDE.md. |
| The agent works from stale information | PROGRESS.md contradicts itself: rewrite "Now" and "Next", delete resolved items. |
| Auto-compact fired | Finish the current step, `/wrap`, start fresh. |
| A task doesn't fit in one session | Split it in plan.md (M2a, M2b). |
| The agent hits the Run limit | The task is too big or its "Done when" too far away. Split it, or wrap and restart with what the runs showed. If healthy sessions hit it, raise the number in AGENTS.md. |
| The plan at Gate 1 keeps being wrong | The plan section is too vague. Put the edge cases and the "Done when" there, not in chat. |
| The same mistake keeps coming back | Add one line to AGENTS.md (or the user-level file if it happens in every project). Remove rules again once models stop needing them. |
| The agent keeps asking what to do next | "Next" in PROGRESS.md isn't concrete enough to start from. |
| "Waiting on me" piles up | You're not checking. Nothing there counts as done; check before starting more. |
| `/start` isn't offered | The commands aren't installed for this agent on this machine (§3). |

---

## 8. Adapting to project types

| Project | Check command | M1 foundation | Notes |
|---|---|---|---|
| Data app (Python) | `pytest` | Load and clean data, rules, tests | Keep the `Data` section and `docs/data.md` |
| Competition or client demo | as above | as above | Keep the `Competition` section: it adds the budget, the time table and the AI log |
| Embedded | Host-side tests (e.g. `pio test -e native`) plus the build | Hardware abstraction layer, drivers, logic tested on the PC | Pin map and errata go in `docs/hardware.md`, with a read-when row. For ESP32 with a test bench, the Embed_WF kit builds on this workflow. |
| Game (Godot) | Headless tests (GUT or gdUnit4) | Core loop and game state | Game feel is yours to tune: expose values as exported variables, and expect "awaiting my check" on most tasks. For strategy and sim games, the Gamedev_WF kit builds on this workflow. |
| Existing codebase | Its own test command | none | No M0; see §3 |
| Comics, writing, art | None | None | This workflow doesn't fit. Use a Claude Project with critique-only instructions. |

**If a project should teach me something** (the old "learn" mode): say so in the task. `/start write the parser, but leave the tokenizer to me` gives a plan whose "done when" is "the scaffold builds and only the tokenizer tests fail". The loop has an end again, which a project-wide learn mode did not give it.

### Building a kit on this workflow

A kit (Embed_WF or Gamedev_WF, for instance) adds a project template and its own commands for one kind of project. It should work with whichever version of this workflow is installed. To make that possible, it relies only on the list below and never copies or restates anything else from this folder. If a kit needs a word that isn't listed, add the word here first, and change the date.

**Contract of 20 November 2026.** A kit's README names the date it was written against.

- **Commands:** `/start <task>`, `/wrap <note>`, `/judge [final]`.
- **AGENTS.md fields the commands read:** Check, Done gate, Run limit, Push, "At /start also", "At /wrap also", "Read only when needed", and "Judged on" (read by `/judge`). The two "also" fields are where a kit adds steps to the bookkeeping at the start and end of a session. Everything else in a kit's AGENTS.md is project facts that the agent follows while it works, such as the order in which test tiers run. The kit's AGENTS.md doesn't repeat the loop or its stop rules; those live in `/start`.
- **PROGRESS.md sections:** Now, Next, Broken, Waiting on me, Done, How to run. An item only I can check waits there as "awaiting my check".
- **docs/:** `history.md` and `decisions.md`, in the formats of `templates/project/docs/`.
- **The plan:** any file that "Read only when needed" points to. Each task in it has a "Done when", or the Done gate applies. If the plan has checkboxes, `/start` and `/wrap` tick them. A kit that marks finished tasks some other way (a status column, say) does it in its "At /start also" and "At /wrap also" steps.
- **Where the workflow lives:** `WORKFLOW_DIR`, which §3 sets once per machine. A kit reads it to find this folder, for instance to copy `templates/project/` files, and stops with a clear message if it isn't set. It never guesses a path.
- **Git commands the workflow runs:** `git pull` (`/start`); `git status`, `git add`, `git commit`, `git show --stat`, and `git push` only as Push allows (`/wrap`); `git add` and `git commit` (`/judge`). A kit that sets up permissions, such as a Claude Code allowlist, allows these plus its own Check and Done gate commands, so a session never waits on a prompt the workflow causes. When a command changes the git commands it runs, this line and the date change with it.
- **Installing a kit's commands:** Linux: `bash "$WORKFLOW_DIR/install.sh" <kit commands folder>`. Windows: the commands `Copy-Item` line from §3, run a second time with the kit's folder. Kit commands use the same file format as `templates/commands/`.

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
| Nothing listed the git commands the workflow runs | §8 lists them; contract of 20 November 2026 | Gamedev_WF's allowlist missed `git pull` (`/start`) and `git show` (`/wrap`), so every session waited on a prompt. Each kit was guessing from the command files. |
| The §8 list left out "Judged on" and said every task has a "Done when" | "Judged on" is listed; a task without "Done when" falls back to the Done gate, as `/start` already did. The list carries a date | Both kits rely on these. The date lets a kit say which version of the list it was written against. |
| `templates/project/.gitignore` ignored `secrets.h` | Removed | It's an embedded detail; Embed_WF's own template already ignores it. |

Not changed on purpose: the split of files by read frequency, the five rules, the snapshot PROGRESS.md, the two gates, the fresh-session review, the bracket markers.
