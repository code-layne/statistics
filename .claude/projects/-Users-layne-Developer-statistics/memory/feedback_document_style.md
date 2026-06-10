---
name: feedback-document-style
description: Layout and style preferences for warmup, key, and slide components
metadata:
  type: feedback
---

**Warmups must fit on one page** and be completable by an average student in ~5 minutes.

**Why:** Warmups that run long or require computation kill pacing at the start of class.

**How to apply:**
- Prefer 3-row data tables over 5-row; fewer rows = less visual load
- Give students pre-computed averages and ask them to evaluate meaning — don't ask them to compute
- One `\writeline` per question is enough; no double write lines for warmup questions
- Remove section headers (Part 1 / Part 2) when a single flow works — fewer headers = more vertical space
- Tighten `\vspace` throughout

**Keys must also fit on one page.**

**Why:** Teacher convenience — a two-page key for a one-page warmup is wasteful.

**How to apply:**
- Answer text should be terse, single-sentence where possible
- Condense sort/classification tables to one content row
- Keep teacher notes to 2 lines max
- Use short `\ans{}` inline answers rather than multi-line blocks

**Slides:** When a lesson has a warmup, add a Warm-Up slide between the title slide and the Primary Objective slide. Reference question topics only — never specific names, numbers, or worksheet details.
