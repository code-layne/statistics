# Build System

The project compiles with **XeLaTeX** (via `latexmk`) and merges PDFs with **`pdfunite`**
(poppler). The skill authors `.tex`; the project's own Makefiles do the building. **Never edit
`shared/` or the Makefiles to make a lesson build — fix the lesson's `.tex` instead.**

## The three-level Make hierarchy

- **Root `Makefile`** — discovers `unit*/Makefile`, delegates, and merges unit PDFs into
  `target/compiled/curriculum_{student,full}.pdf`.
- **`shared/unit.mk`** (included by each `unitXX/Makefile`) — discovers `lesson*/Makefile`,
  delegates, and merges lesson PDFs into `target/compiled/unitXX_{student,full}.pdf`.
- **`shared/lesson.mk`** (included by each `lessonYY/Makefile`, which is just
  `include ../../shared/lesson.mk`) — the engine. It:
  - **Discovers a component if it has `main.tex` or `main.pdf`.** Authored components
    (`main.tex`) are compiled; prefab components (`main.pdf`) are used as-is from the source
    tree. A directory with neither is skipped.
  - Compiles each `<comp>/main.tex` with
    `latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error`,
    sending output to `target/UNIT/LESSON/<comp>/` and a stamp to `.stamps/`.
  - Builds two merged packets:
    - **student** = `cover warmup notes activity exit_ticket homework` (blank versions present),
      in that pedagogical order → `lessonYY_student.pdf`.
    - **full** = the lesson plan (`main.tex`) + `slides` + `cover` + the **`_key`** version of
      each keyed component (falling back to the blank if no key) → `lessonYY_full.pdf`.

## Commands

```bash
make -C unitXX/lessonYY student   # student packet for one lesson
make -C unitXX/lessonYY full      # teacher/full packet (plan + slides + keys)
make -C unitXX/lessonYY all       # both (runs student then full)
make -C unitXX/lessonYY clean     # remove this lesson's target/ and stamps

make -C unitXX student|full       # merge a whole unit
make student|full                 # merge the whole curriculum (from project root)
make clean | distclean            # clean everything (distclean also removes target/ and .stamps)
```

Outputs land in `target/`: per-component PDFs under `target/UNIT/LESSON/<comp>/main.pdf`,
merged packets under `target/compiled/`.

**Always build with `make all` (or `student` before `full`)** when the lesson plan embeds a
warm-up thumbnail: the thumbnail uses the warm-up, and `full` alone (from a clean tree) builds
only the `_key` versions. Authored warm-ups are text-only in the plan (no thumbnail); prefab
warm-ups embed `warmup/main` (the PDF in the source tree), which resolves regardless of order.

## Scaffolding a lesson

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/new_lesson.py --project . --unit 02 --lesson 03 \
  --title "..." --unit-title "..." \
  --components cover,warmup,notes,activity,exit_ticket,homework[,slides] \
  [--prefab warmup,warmup_key] [--course "Algebra 2: Shepherd"] [--lesson-id 2.3]
```

It detects the prefix from `shared/*-colors.sty`, detects whether `\CourseName` is defined in
`shared/` (omitting it from the plan if so, inlining it if not), writes the one-line `Makefile`,
the lesson plan, and each authored component + key skeleton. Pass `--prefab <dirs>` to create
empty drop-in directories instead (where you place each `main.pdf`). Then author the skeletons
(`references/components.md`).

## Prefab PDFs

To include a ready-made PDF as a component, drop it in as `<comp>/main.pdf` (and
`<comp>_key/main.pdf` for a prefab key). `lesson.mk` discovers it and feeds it straight to
`pdfunite` — no `main.tex`, no compile step. `make clean` removes only `target/` and stamps, so
your source PDFs are never deleted. (Requires the `lesson.mk` that discovers `main.pdf`; older
Makefiles that glob only `main.tex` will silently omit prefab-only components — update first.)

## Troubleshooting

`-file-line-error` makes errors report as `file:line: message`. Read the component's log at
`target/UNIT/LESSON/<comp>/main.log`. Common issues:

- **`File 'warmup/main' not found`** in the lesson plan → the plan embeds a thumbnail but the
  warm-up isn't built/present. Build `student` first, or (authored warm-ups) keep the spiral
  review text-only, or (prefab) ensure the PDF is present as `warmup/main.pdf` so the thumbnail
  (`\includegraphics{warmup/main}`) resolves.
- **`Undefined control sequence \CourseName`** → the course macros aren't defined. Either the
  style package defines them (apstats) or the lesson plan must (algebra2); the scaffolder picks
  the right one, but a hand-edited plan may have dropped them.
- **`\includegraphics` fails for a screenshot** → put images in `images/` (the plan sets
  `\graphicspath{{images/}}`) and load `graphicx` (the plan does; `-article` does not).
- **Key won't compile / option clash** → a key loads `-key` only; do **not** also load
  `-boxes` (it's pulled in). Mirror the blank, swapping that one package line.
- **Garbled glyphs or font errors** → the build is XeLaTeX-only (it uses `unicode-math` /
  `fontspec`-style features); don't compile with `pdflatex`. `latexmk -xelatex` is set in
  `lesson.mk`.
- **`pdfunite: command not found`** → install poppler-utils.
- **A new component didn't appear in the packet** → its directory has neither `main.tex` nor
  `main.pdf`, or its name isn't in `STUDENT_ORDER`/`KEY_ORDER`. Use the standard component names.

If a fix seems to require changing `shared/` or a Makefile, stop and raise it — that's a
project-level refactor, not a per-lesson change.
