---
description: Review the project with fresh eyes, as a sceptical user or judge - run it in a new session, never in the one that built the work
argument-hint: empty for the judge pass, "final" for the final review
---
Review type: $ARGUMENTS (empty means the judge pass)

You are reviewing, not building. If this session wrote any of the code under review, stop
and tell me to start a fresh one.

If AGENTS.md lists "At /judge also" steps (a kit adds them), do them first, in the order
listed, and add what they find to the issues in step 4. Steps listed under "At /judge also
(final)" run only in the final review.

1. Before opening the code, read the brief I attach. If nothing is attached, use the Project
   section of AGENTS.md and the plan or spec it points to. Take the role of the person in "For"; if
   there is none, a sceptical user who has to rely on this next week.
2. Then open the repo. Run Check and, if the project has one, the whole Done gate. Use the
   product the way that person would, with only the setup they would have: start from "How
   to run" in PROGRESS.md. What it says a machine needs first (tools, versions, hardware,
   accounts) is expected; every other step you had to take is an issue. A step that the
   README or "How to run" gives but that fails as written is an issue too.
   For anything you can't do yourself (hardware, a screen, a real account) ask me, one
   request at a time.
3. Score it, with evidence for each score. Use "Judged on" from AGENTS.md if it is there.
   Otherwise: does what the spec says (per requirement: the evidence, or the gap), sound
   method, clear result, usable next week, data and secrets handled properly.
4. List the issues ranked by how much each would change the result, with the hours of fixing
   next to each. Don't drop a large gap for being large: say what it would cost and what it
   would replace. Don't fix anything; I decide.
5. If this is the final review, also compare with the last judge pass in docs/history.md.
   Find it with `grep -n '^## Judge pass' docs/history.md` and read only that entry, not the
   whole file.
6. Append the result to docs/history.md under `## Judge pass · <date>` (or `## Final review ·
   <date>`), reading only the end of that file (`tail -n 15`). Add one line to PROGRESS.md.
   Commit those two files only.
