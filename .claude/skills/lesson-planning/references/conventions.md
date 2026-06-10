# Conventions

Extracted from the `shared/<prefix>-*.sty` packages. The live project is always the source
of truth — if a course's styles diverge from this, follow the course. Replace `<prefix>`
with the detected prefix (`algebra2`, `apstats`, …) everywhere below.

## Style packages

| Package | Purpose | Required by |
| --- | --- | --- |
| `<prefix>-colors` | Color palette (loads `xcolor`) | everything |
| `<prefix>-article` | Article preamble: geometry, lists, fill-in helpers, page header, name rows | student components |
| `<prefix>-boxes` | All `tcolorbox` environments | components + lesson plan |
| `<prefix>-key` | Answer macros + teacher note; requires `-boxes` | answer keys |
| `<prefix>-beamer` | Slide theme | `slides/` |

## Per-document-type preambles

**Student component** (warmup, notes, activity, exit_ticket, homework, cover):
```latex
\documentclass[10pt]{article}
\usepackage{<prefix>-article}
\usepackage{<prefix>-boxes}
% cover and some components also: \usepackage{ltablex}\keepXColumns
```

**Answer key** (the matching `_key` directory):
```latex
\documentclass[10pt]{article}
\usepackage{<prefix>-article}
\usepackage{<prefix>-key}     % pulls in -boxes; do NOT also load -boxes
```

**Lesson plan** (`main.tex` at the lesson root): loads `-boxes` (and usually `-colors`
implicitly through it) and defines the course/unit/lesson macros it needs. Note the two
observed styles — detect which the course uses:
- `apstats` defines `\CourseName`, `\SchoolYear`, `\MeetingLength` in its style package, so
  the lesson plan only sets `\UnitNumberName` and `\LessonNumberName`.
- `algebra2` defines all of them inline in the lesson plan preamble and loads a richer set of
  packages directly (`pdfpages`, `graphicx` with `\graphicspath{{images/}}`, `tabularx`,
  `unicode-math`, `multicol`).

The `\TallMath` helper used for tall inline math is defined per-document where needed:
```latex
\newcommand{\TallMath}[1]{$\displaystyle #1\rule[-1.4em]{0pt}{3.2em}$}
```

## Fill-in helpers (from `-article`)

| Macro | Effect |
| --- | --- |
| `\blank{width}` | Underlined gap of the given width (e.g. `\blank{4.8cm}`) |
| `\writeline` | A full-width gray rule to write on |
| `\writelines{n}` | `n` stacked write-lines |
| `\termblank{Term}` | Bold navy term + inline blank, then a write-line |
| `\termblanklong{Term}` | Bold navy term on its own line + two write-lines (vocab style) |
| `\namedateperiod` | Name / Date / Period row |
| `\namepartnerperiod` | Name / Partner / Period row (group activities) |
| `\pageheader{Unit X, Lesson Y.Z}{Document Type}` | Full-width navy banner header |

## Box environments (from `-boxes`)

Lesson-plan boxes take a background color as the last argument (use the aliases `goldbox`,
`greenbox`, `redbox`, or palette colors like `sky`):
```latex
\begin{skillbox}[Priority Ideas \& Skills]{goldbox} ... \end{skillbox}   % breakable
\begin{fixedskillbox}[Spiral Review]{sky} ... \end{fixedskillbox}        % no page break
```

Titled student boxes (title is fixed by the environment unless it takes an argument):

| Environment | Title / use | Arg |
| --- | --- | --- |
| `objectivebox` | "Primary Objective" | — |
| `learningtargetbox` | "Learning Targets — I Can…" (cover sheet) | — |
| `vocabbox` | "Vocabulary & Key Concepts" | — |
| `hookbox` | "Hook" | — |
| `notesbox{Title}` | generic titled notes section | title |
| `practicebox` | "Guided Practice" | — |
| `spiralbox` | "Connections & Big Ideas" | — |
| `scenariobox[Title]{color}` | activity/homework scenario | title, color |
| `headlinebox{color}` | colored callout strip | color |
| `blurbbox[Title]{color}` | study/excerpt blurb | title, color |
| `reflectionbox` | "Reflection" (homework) | — |
| `extensionbox` | "Extension — optional" | — |
| `tocbox` | "What's in This Packet" (cover) | — |
| `remindbox` | "Keep in Mind" (cover) | — |

Reusable component-identification table (AP Stats):
- `\componenttable` — blank version (student), four rows: Individual / Population / Sample / Variable(s).
- `\componenttablekey{ind}{pop}{samp}{vars}` — filled version (key), defined in `-key`.

## Answer-key macros (from `-key`)

| Macro / env | Effect |
| --- | --- |
| `\ans{text}` | Inline answer in bold `keyred`; use in place of a blank |
| `\ansline{text}` | Bold `keyred` answer that fills a write-line with a dotted trail |
| `\componenttablekey{..}{..}{..}{..}` | Filled component-ID table |
| `teachernote` (env) | Red "Teacher Note" callout for teacher-only guidance |

**Key-authoring rule:** copy the blank component verbatim, then replace each blank/`\writeline`
with `\ans{…}`/`\ansline{…}` and mark correct multiple-choice options, e.g.
`\textcolor{keyred}{\textbf{$\leftarrow$ correct}}`. The key and blank must stay structurally
identical so they paginate the same way.

## Color palette (from `-colors`)

Primary: `navy` (#1F3A5F), `navylight`, `sky` (pale blue bg), `skymid`, `goldacc`, `goldbg`,
`greenbg`/`greenacc`, `redbg`/`redacc`, `charcoal`, `slate`, `linegray`, `keyred` (#CC0000).
Lesson-plan background aliases: `goldbox`, `greenbox`, `redbox`.

## Lesson-plan section order (canonical)

Primary Objective → Priority Ideas & Skills → Vocabulary, Concepts & Theorems → Activate
Prior Knowledge & Spiral Review (embeds the warm-up thumbnail) → Hook → Lesson (and
"Lesson (cont.)") → Explicit Instruction (one box per technique) → Active Monitoring →
Group Work & Differentiation (Tiers R / A / E) → Individual Work & Assessment (Exit Ticket +
SOL/AP-style MC) → Reinforcement & Extension (Homework + Extension + Preview). For AP courses,
tag the objective and skills with the Big Idea and AP Skill (see `ap-workflow.md`).
