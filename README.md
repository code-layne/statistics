# AP Statistics Curriculum

A LaTeX-based curriculum for AP Statistics, organized by unit and lesson. Includes slides, notes, activities, homework, exit tickets, and answer keys — all built from source into print-ready PDFs.

## Structure

Each lesson lives in `unitXX/lessonXX/` and compiles to a set of PDFs:

- `notes` / `notes_key`
- `warmup` / `warmup_key`
- `activity` / `activity_key`
- `exit` / `exit_key`
- `homework` / `homework_key`
- `cover` (lesson cover sheet)

## Building from Source

Requires [XeLaTeX](https://tug.org/xetex/) and `latexmk`.

```bash
make all        # compile all units
make unit01-pdf # compile + merge Unit 1 into a single PDF
make unit02-pdf # compile + merge Unit 2 into a single PDF
```

Output lands in `target/`.

## Downloading Prebuilt PDFs

> Coming soon — versioned releases for each unit will be available on the [Releases](../../releases) page.

## License

TBD
