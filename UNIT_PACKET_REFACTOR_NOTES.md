# Unit Packet Refactor Notes

Context saved after the Unit 1 refactor. Use this when applying the same change
to other units.

## Goal

Build unit-level packets from TeX wrapper files instead of `pdfunite` whenever a
unit provides:

- `unitXX_student.tex`
- `unitXX_full.tex`

This gives the combined packet one continuous page-number sequence.

## Current Architecture

- `shared/unit.mk` detects the optional unit wrapper files.
- If a wrapper exists, the unit target compiles the wrapper with `latexmk`.
- If no wrapper exists, the unit target falls back to the old `pdfunite` merge.
- Lesson-level builds still produce the component PDFs needed by the wrappers.

## Student Packet Pattern

For each unit, create `unitXX_student.tex` that source-includes:

1. `unit_cover`
2. each lesson's student-facing components in order:
   - `cover`
   - `warmup`
   - `notes`
   - `activity`
   - `exit_ticket`
   - `homework`
3. `sample_test/main.pdf`, if present

Use `docmute` and `import` to include component `main.tex` files from source.
Use `pdfpages` only for prefab PDFs such as sample tests.

## Full Teacher Packet Pattern

For each unit, create `unitXX_full.tex` that source-includes:

1. `unit_cover`
2. each lesson plan from source, not as an inserted PDF
3. a 3-up slide handout, only in the full packet
4. each lesson's keyed components in order:
   - `cover`
   - `warmup_key`
   - `notes_key`
   - `activity_key`
   - `exit_ticket_key`
   - `homework_key`
5. `sample_test/main.pdf`, if present
6. `sample_test_key/main.pdf`, if present

Do not insert the lesson plan as a PDF. Use `\subimport{lessonYY/}{main.tex}`
so the lesson plan participates in the full packet page numbering.

## Slides

Keep the normal lesson slide artifact as:

- `unitXX/lessonYY/slides/main.pdf`

That PDF remains one slide per page and can be imported into Google Slides.

In the full teacher packet only, include those slide PDFs as printable handouts:

- portrait letter page
- 3 slides per page
- slide thumbnails in a left column
- matching `Notes:` area for each slide in a right column

Do not generate or require PowerPoint files for this workflow.

The current Unit 1 wrapper hard-codes each lesson's slide page count:

- lesson01: 9
- lesson02: 16
- lesson03: 12
- lesson04: 13
- lesson05: 11
- lesson06: 12
- lesson07: 13
- lesson08: 11
- lesson09: 11
- lesson10: 13

For other units, get page counts from the compiled lesson slide PDFs with
`pdfinfo`.

## Lesson Plan Source-Inclusion

Lesson plans may need small adjustments before they can be source-included:

- metadata definitions such as `\UnitNumberName` and `\LessonNumberName` should
  live after `\begin{document}` when needed
- avoid preamble-only code that assumes the lesson plan is always compiled as a
  root document
- use local grouping around `\subimport` calls in the unit wrapper
- if a lesson needs tighter margins, pass a custom option to the lesson-plan
  include macro, as Unit 1 Lesson 1 does

## Build And QA

After adding wrappers for a unit:

1. Delete stale stamps for that unit if source files changed.
2. Run `make -C unitXX student`.
3. Run `make -C unitXX full`.
4. Check page count and page size with `pdfinfo target/compiled/unitXX_full.pdf`.
5. Render at least:
   - the first slide handout page
   - the last slide handout page for a lesson with a non-multiple-of-3 slide count
6. Visually confirm slide thumbnails and notes areas do not overlap or clip.

Unit 1 reference result after this refactor:

- `target/compiled/unit01_student.pdf`: 111 pages
- `target/compiled/unit01_full.pdf`: 175 letter-size pages

## Do Not Reintroduce

- Do not use `pdfunite` for units that have wrapper TeX files.
- Do not insert lesson plans into the full packet as PDFs.
- Do not include slides in the student packet.
- Do not add a Node or PowerPoint generation step for this workflow.
- Do not remove the one-slide-per-page `slides/main.pdf`; it is the display and
  Google Slides import artifact.
