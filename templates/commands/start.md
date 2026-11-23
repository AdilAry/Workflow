---
description: Start a short session on one task - a plan section, an ID, or free text
argument-hint: task, e.g. M2 or "fix the export" (empty = Next in PROGRESS.md)
effort: high
---
Task for this session: $ARGUMENTS

The project's AGENTS.md defines **Check**, **Done gate**, **Run limit** and **Push**.

1. Run `git pull` (skip it if the repo has no remote). Read PROGRESS.md. If no task was given,
   take item 1 under "Next".
2. If PROGRESS.md and the code disagree, tell me before anything else.
3. If "Waiting on me" lists work awaiting my check, ask me in your reply whether each one
   passed, and plan as if it did. If I reject one, stop: I type `/start` with that item, and it
   becomes the session's task.
4. Read only what the task needs: its own section of the plan (AGENTS.md "Read only when
   needed" says where). Not the whole file, not the whole codebase. If that section names no
   edge cases, or its "Done when" names no command or file, add at most 3 questions to your
   reply, each with a suggested answer, and plan on those answers. A task with no plan section
   skips this.
5. Don't wait for answers before planning: the plan must come in this reply. Reply with the
   questions from steps 3 and 4, if any, then a plan of at most 5 bullets:
   - the steps, smallest first, tests before the code they prove, and the files you expect to touch;
   - **done when:** the exact command that will prove it works: the plan's "Done when" if the
     section has one, otherwise the Done gate. For a task with no code (docs, research, a
     decision) there is no command: name the file that must exist and what it must say, and
     that I approve it. Never invent a check;
   - what only I can check by hand;
   - anything that needs my hands or a decision from me;
   - any step git can't undo (deploy, a push beyond what Push in AGENTS.md allows, send, flash
     fuses, delete or migrate data outside git), or "none". Do none of them before I say so
     for that step.
   If the task doesn't fit one session, don't plan it: propose the split.
6. Wait for my OK, which also answers your questions. Change no file before it. If my answers
   change more than one bullet of the plan, say so and stop: I type `/start` again for a new plan.
7. After my OK, do the bookkeeping first: record the checks I confirmed (append its entry to
   docs/history.md, reading only the end of that file with `tail -n 15`; move it from
   "Waiting on me" to "Done"; if the plan has checkboxes, tick it), write my answers from step 4
   into that plan section, and do every "At /start also" step AGENTS.md lists. Then work the plan. You may loop on your own (edit, run, read
   the failure, fix, run again) until "done when" passes. Stop and report when:
   - you need to change something that isn't in the plan and isn't a small consequence of it;
   - the same failure has survived 3 different fixes;
   - passing would mean changing or deleting an existing test the plan doesn't name: tell me
     which test and why you think it's wrong, and leave it as it is;
   - you have made as many test or build runs as the Run limit, counting every run, passed or
     failed (20 if AGENTS.md gives none);
   - something needs my hands, or the plan or spec is ambiguous, contradictory or wrong.
8. When it passes, or you stopped: report in 5 lines or fewer (the result, the output line that
   proves it, what's left). Then tell me what to check and to type /wrap.
