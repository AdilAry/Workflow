---
description: Review the project with fresh eyes, as a sceptical user or judge - run it in a new session, never in the one that built the work
argument-hint: empty for the judge pass, "final" for the final review
---
Review type: $ARGUMENTS (empty means the judge pass)

You are reviewing, not building. If this session wrote any of the code under review, stop
and tell me to start a fresh one.

If AGENTS.md lists "At /judge also" steps (a kit adds them), do them first, in the order
listed, and add what they find to the issues in step 5. A step marked final runs only in the
final review.

1. Before opening the code, read the brief I attach. If nothing is attached, use the Project
   section of AGENTS.md and the plan or spec it points to. Take the role of the person in "For"; if
   there is none, a sceptical user who has to rely on this next week.
2. Then open the repo. Run Check and, if the project has one, the whole Done gate. Use the
   product the way that person would, starting from the hand-in or the demo link and its
   README alone: every setup step you had to take is an issue. For anything you can't do
   yourself (hardware, a screen, a real account) ask me, one request at a time.
3. Score it, with evidence for each score. Use "Judged on" from AGENTS.md if it is there.
   Otherwise: does what the spec says (per requirement: the evidence, or the gap), sound
   method, clear result, usable next week, data and secrets handled properly.
   If AGENTS.md has an "Official score": run it, and say whether the materials report the
   result against the baseline in one line.
4. If AGENTS.md has a "First question": ask it and read the top results. Do they answer it
   usefully? Does every user group named there get something it can use?
   If it has a "Title question": which built thing answers it? A page of text doesn't count.
   If it has a "Competition" section, also:
   - Describe the entry that would win on this brief: what it builds, what it shows first,
     the number it closes on. List what it has that this one lacks.
   - Re-read "Not doing" in AGENTS.md. Name every line that the brief, the sponsor's answers
     or your own findings now argue against.
   - In the headline text of the hand-in (title, tagline, first lines of the description),
     list every sentence that argues against the project's own value. Each one moves to the
     limits section or the Q&A answers. Labels that say where the data comes from stay.
5. List the issues ranked by how much each would change the result, with the hours of fixing
   next to each. Don't drop a large gap for being large: say what it would cost and what it
   would replace. Don't fix anything; I decide.
6. If this is the final review, also: check every item in "Hand-in" if there is one;
   compare with the last judge pass in docs/history.md.
7. Append the result to docs/history.md and add one line to PROGRESS.md. Commit those two
   files only.
