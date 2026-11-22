---
description: Turn my idea into AGENTS.md and docs/plan.md by asking me questions, top down - once, at the start of a project
argument-hint: the idea in a few sentences
---
My idea: $ARGUMENTS

You fill in this project's AGENTS.md and docs/plan.md from my answers; I approve what you write
instead of filling them in myself. Each `[...]` in them is a field: `[a | b]` is a choice,
`[IF ...]` marks an optional line or section.

1. Read docs/plan.md (AGENTS.md is already loaded). If the repo already has code, look at its
   structure first and ask only what the code can't tell you. If my idea is missing, ask me for
   it in a few sentences and wait.
2. Ask me one question at a time, top down. Start a level only once the one above is settled:
   1. **What and why:** Project, Scope (one sentence, MVP, not doing, constraints), and which of
      the optional sections apply (Problem, Data). If someone else judges the result against
      criteria and a deadline, tell me that the Pitch_WF kit's /entry adds that part later.
   2. **How:** Stack (language and tools, Run, Check, Push, hardware, deploy) and the fields of
      the optional sections I kept.
   3. **In what order:** what each plan section delivers, and its "Done when".
   Give every question a suggested answer, from my idea, the answers so far and the user-level
   file, so I can just say yes. Skip a field my idea already answers, and say what you took
   from it. Go no lower than a field needs: the detail of one task belongs in its /start.
3. Write both files. Fill every field; delete the IF lines and sections that don't apply, and
   the markers on those that do. Keep AGENTS.md under ~120 lines.
4. Run `grep -n '\[' AGENTS.md docs/plan.md` and fix what it finds, until it finds nothing.
5. Reply in 5 lines or fewer: what you assumed without asking, and anything still waiting on a
   decision. This task has no code: it is done when both files have no brackets left and I
   approve them. Tell me to read both, then to type /wrap; "Next" is `/start M0`.
