---
name: lesson-planning
description: >-
  Author complete, build-ready lessons for a LaTeX-based curriculum project (one with a
  shared/ style package and a Makefile hierarchy that compiles components with latexmk
  and merges them with pdfunite). Use this whenever the user wants to create, draft, or
  build a lesson, a lesson plan, a unit, or any lesson component — warm-up, guided notes,
  activity, exit ticket, homework, cover sheet, or their answer keys — for a course like
  Algebra 2 or AP Statistics. If the course has College Board AP CED documents (files
  named ap-*), use them to drive objectives, skills, and standards; otherwise generate
  from a lesson title, description, and a list of standards. Trigger this even when the
  user just says "make lesson 2.3" or "I need a warm-up and key for tomorrow," and even
  if they don't say the words "skill" or "LaTeX."
---

# Lesson Planning

This skill authors lessons for an existing LaTeX curriculum project and produces print-ready
PDFs through the project's own build system. **It builds around the project's conventions —
it does not invent its own.** The two reference courses (`algebra2`, `apstats`) are
structurally identical: only the style-package prefix differs.

## What a lesson is

A lesson lives in `unitXX/lessonYY/` and consists of:

- **`main.tex`** — the teacher-facing **lesson plan** (the root document of the lesson dir).
- A set of **student components**, each its own subdirectory containing **either** a `main.tex`
  (authored, compiled to a PDF) **or** a `main.pdf` (a prefab PDF, used as-is):
  `cover`, `warmup`, `notes`, `activity`, `exit_ticket`, `homework`, and optional `slides`.
- An **answer key** for each keyed component, as a *separate* sibling directory:
  `warmup_key`, `notes_key`, `activity_key`, `exit_ticket_key`, `homework_key`.
  (`cover` has no key.)

`shared/lesson.mk` discovers a component if it has a `main.tex` **or** a `main.pdf`, compiles
the `main.tex` ones with `latexmk -xelatex`, and merges all of them with `pdfunite` in
pedagogical order into `lessonYY_student.pdf` (cover + blank components) and `lessonYY_full.pdf`
(cover + keyed versions, plus the lesson plan and slides). A prefab `main.pdf` is fed straight
to `pdfunite` from the source tree with no compile step — so dropping in a ready-made PDF is all
that's needed (Step 4).

## Workflow

Follow these steps in order. Read the referenced files as you reach each step rather than
all upfront.

### Step 0 — Detect project context (always do this first)

Never assume the prefix or conventions. Inspect the project:

1. **Find the prefix.** `ls shared/*-colors.sty` → the prefix is the part before `-colors.sty`
   (e.g. `algebra2`, `apstats`). All `\usepackage{<prefix>-article}` etc. must use it.
2. **Learn course-level macros.** Grep the shared styles and an existing lesson plan for
   `\CourseName`, `\SchoolYear`, `\MeetingLength`, `\UnitNumberName`, `\LessonNumberName`.
   Some courses define course-level macros inside the style package (apstats); others define
   them per lesson plan (algebra2). Define in the new files only what isn't already provided.
3. **Choose the input path.** Look for College Board CED files in a `spec/` directory, named
   `ap-*.pdf` (the detailed `...course-and-exam-description.pdf`, the `...course-at-a-glance.pdf`,
   and supporting overview/poster files). If present → **AP path** (`references/ap-workflow.md`).
   If absent → **standards path** (`references/standards-workflow.md`). In an AP course, one CED
   **Topic** (e.g. Topic 1.1) maps to one lesson (Lesson 1.1).
4. **Find the insertion point.** List `unit*/lesson*` to determine the next unit/lesson
   number and whether the target lesson already exists.
5. **Read one built lesson as a model.** Open an existing fully-built lesson in the same
   course (or, if none, the closest sibling course) and mirror its preamble lines, box usage,
   and tone. Conventions are summarized in `references/conventions.md`, but the live project
   is the source of truth.

### Step 1 — Gather inputs

- **AP path:** locate the CED, extract the unit → topic → Learning Objective → Essential
  Knowledge content relevant to this lesson, plus the governing Big Idea and AP Skill. See
  `references/ap-workflow.md`. Confirm the topic mapping with the user before authoring.
- **Standards path:** collect the lesson title, a short description, and the list of standards
  being addressed. See `references/standards-workflow.md`.

Either way, the lesson-plan *structure* is identical (`references/components.md` → "Lesson
plan"). Review units (e.g. Algebra 2 Unit 1) use the same skeleton; they simply fill the
Priority Ideas & Skills with review topics and usually carry no AP-framework tags.

### Step 2 — Scaffold the lesson directory

Run the scaffold script, which creates the directory, the one-line `Makefile`
(`include ../../shared/lesson.mk`), and the component subdirectories you request:

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/new_lesson.py --project . --unit 02 --lesson 03 \
  --components cover,warmup,notes,activity,exit_ticket,homework,slides
```

The script is bundled with the skill, so it is invoked via `${CLAUDE_SKILL_DIR}` (the working
directory at runtime is the user's project, not the skill folder); `--project .` is the project
root you're working in.

It auto-detects the prefix and writes each authored component's `main.tex` as a correctly-
preambled skeleton (and the matching `_key` skeleton for keyed components). Pass `--prefab warmup`
to create that component as an empty drop-in directory instead, where you place the supplied
`main.pdf` (Step 4). Then fill in the skeletons.

### Step 3 — Author the lesson plan and components

Author each file following `references/components.md`, which gives the required section
structure and a worked skeleton for every component and its key. Hold to these invariants:

- **Student components** preamble with `\documentclass[10pt]{article}` +
  `\usepackage{<prefix>-article}` + `\usepackage{<prefix>-boxes}`.
- **Answer keys** are *separate files* that swap `-boxes` for `\usepackage{<prefix>-key}`
  and wrap every answer in `\ans{...}` (inline) or `\ansline{...}` (fills a write-line).
  Mirror the blank document exactly, then fill the blanks with `\ans`. Use `teachernote`
  for teacher-only guidance. There is **no** answer-key toggle — never try to build one.
- Use the project's box vocabulary (`skillbox`, `objectivebox`, `learningtargetbox`,
  `vocabbox`, `hookbox`, `notesbox`, `practicebox`, `scenariobox`, `tocbox`, etc.) and
  fill-in helpers (`\blank`, `\writeline`, `\termblanklong`, `\namedateperiod`) rather than
  reinventing layout. The full catalog is in `references/conventions.md`.
- If the warm-up is a **prefab** PDF (`warmup/main.pdf` in the source tree), the lesson plan may
  embed its thumbnail via `\includegraphics[page=1]{warmup/main}`. **Authored** warm-ups compile
  to `target/` and have no source PDF to embed, so keep the spiral review text-only (as AP Stats
  does); the scaffolder picks the right form automatically.

### Step 4 — Handle prefab components

When the user supplies a ready-made PDF for a component (a pre-built warm-up, a publisher
worksheet), just drop it in — no wrapper needed:

1. Place the PDF as `<comp>/main.pdf` (e.g. `warmup/main.pdf`).
2. If the key is also a prefab PDF, place it as `<comp>_key/main.pdf`.

`shared/lesson.mk` discovers the component by its `main.pdf` and feeds it straight to `pdfunite`,
skipping compilation. Use `--prefab <comp>` when scaffolding to create the empty drop-in
directory. (This relies on the `lesson.mk` that supports prefab `main.pdf` discovery — if a
project's Makefile still only globs `main.tex`, update it first; see `references/build.md`.)

### Step 5 — Build

Build from the lesson directory (or the unit/root for wider packets):

```bash
make -C unit02/lesson03 student   # cover + blank student components → lessonYY_student.pdf
make -C unit02/lesson03 full      # lesson plan + slides + keyed versions → lessonYY_full.pdf
make -C unit02/lesson03 all       # both
```

`make -C unit02 student|full` merges a unit; `make student|full` at the root merges the whole
curriculum. Output lands in `target/`. The build needs XeLaTeX, `latexmk`, and `pdfunite`;
if a compile fails, surface the `.log` and fix the offending `.tex` rather than editing the
build system. Details and troubleshooting in `references/build.md`.

## Reference files

- `references/conventions.md` — the style packages, every box environment, the fill-in and
  answer-key macros, color palette, and per-document-type preambles. Read before authoring.
- `references/components.md` — section-by-section spec and a skeleton for the lesson plan and
  each component + key.
- `references/ap-workflow.md` — reading an AP CED and mapping Big Idea / Skill / LO / EK into
  the lesson.
- `references/standards-workflow.md` — the title + description + standards path.
- `references/build.md` — the Makefile hierarchy, scaffolding, prefab PDFs, build commands,
  and troubleshooting.

## Guardrails

- Detect, don't assume: prefix, course macros, and the AP-vs-standards path all come from
  inspecting the project (Step 0).
- Mirror an existing built lesson for tone and preamble; the live project overrides this doc.
- Keep blank and key documents in lockstep — the key is the blank with answers filled in.
- Don't modify `shared/` or the Makefiles to make a lesson build; fix the lesson's `.tex`.
