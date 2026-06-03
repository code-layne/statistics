.PHONY: all clean distclean units unit01-pdf unit02-pdf \
        unit01-lesson01-student unit01-lesson01-full

PROJECT_ROOT := $(CURDIR)
TEXINPUTS    := $(PROJECT_ROOT)/shared//:

LATEXMK      = latexmk
LATEXFLAGS   = -xelatex \
               -interaction=nonstopmode \
               -halt-on-error \
               -file-line-error

# ── Source discovery ──────────────────────────────────────────────────────────
SHARED_STYS  := $(wildcard shared/*.sty)
UNIT01_MAINS := $(shell find unit01 -name main.tex | sort)
UNIT02_MAINS := $(shell find unit02 -name main.tex | sort)
ALL_MAINS    := $(UNIT01_MAINS) $(UNIT02_MAINS)

# ── Stamp paths (mirror source tree under .stamps/) ───────────────────────────
# A stamp is touched after each successful compilation; Make uses it to decide
# whether recompilation is needed on the next `make all`.
UNIT01_STAMPS := $(patsubst %.tex, .stamps/%.stamp, $(UNIT01_MAINS))
UNIT02_STAMPS := $(patsubst %.tex, .stamps/%.stamp, $(UNIT02_MAINS))
ALL_STAMPS    := $(UNIT01_STAMPS) $(UNIT02_STAMPS)

# ── PDF paths derived from source paths (used by pdfunite) ───────────────────
UNIT01_PDFS  := $(patsubst %.tex, target/%.pdf, $(UNIT01_MAINS))
UNIT02_PDFS  := $(patsubst %.tex, target/%.pdf, $(UNIT02_MAINS))

# ── Default target ────────────────────────────────────────────────────────────
all: $(ALL_STAMPS)

# ── Pattern rule: one main.tex → one stamp ────────────────────────────────────
# Prerequisites: the source file + every shared .sty file.
# Recompiles only when the source or a shared style changes.
.stamps/%.stamp: %.tex $(SHARED_STYS)
	@mkdir -p $(dir $@) target/$(dir $*)
	cd $(dir $<) && \
		TEXINPUTS="$(TEXINPUTS)" \
		$(LATEXMK) $(LATEXFLAGS) \
		-outdir="$(PROJECT_ROOT)/target/$(dir $<)" main.tex
	@touch $@

# ── Unit bundles ──────────────────────────────────────────────────────────────
units: unit01-pdf unit02-pdf

unit01-pdf: $(UNIT01_STAMPS)
	mkdir -p target/compiled
	pdfunite $(UNIT01_PDFS) target/compiled/unit01.pdf

unit02-pdf: $(UNIT02_STAMPS)
	mkdir -p target/compiled
	pdfunite $(UNIT02_PDFS) target/compiled/unit02.pdf

# ── Lesson 1.1 component lists ────────────────────────────────────────────────
U01_L01 := target/unit01/lesson01

U01_L01_STUDENT_STAMPS := \
    .stamps/unit01/lesson01/cover/main.stamp \
    .stamps/unit01/lesson01/warmup/main.stamp \
    .stamps/unit01/lesson01/notes/main.stamp \
    .stamps/unit01/lesson01/activity/main.stamp \
    .stamps/unit01/lesson01/exit_ticket/main.stamp \
    .stamps/unit01/lesson01/homework/main.stamp

U01_L01_STUDENT_PDFS := \
    $(U01_L01)/cover/main.pdf \
    $(U01_L01)/warmup/main.pdf \
    $(U01_L01)/notes/main.pdf \
    $(U01_L01)/activity/main.pdf \
    $(U01_L01)/exit_ticket/main.pdf \
    $(L01)/homework/main.pdf

U01_L01_FULL_STAMPS := \
    .stamps/unit01/lesson01/main.stamp \
    .stamps/unit01/lesson01/slides/main.stamp \
    .stamps/unit01/lesson01/cover/main.stamp \
    .stamps/unit01/lesson01/warmup/main.stamp \
    .stamps/unit01/lesson01/warmup_key/main.stamp \
    .stamps/unit01/lesson01/notes/main.stamp \
    .stamps/unit01/lesson01/notes_key/main.stamp \
    .stamps/unit01/lesson01/activity/main.stamp \
    .stamps/unit01/lesson01/activity_key/main.stamp \
    .stamps/unit01/lesson01/exit_ticket/main.stamp \
    .stamps/unit01/lesson01/exit_ticket_key/main.stamp \
    .stamps/unit01/lesson01/homework/main.stamp \
    .stamps/unit01/lesson01/homework_key/main.stamp

U01_L01_FULL_PDFS := \
    $(U01_L01)/main.pdf \
    $(U01_L01)/slides/main.pdf \
    $(U01_L01)/cover/main.pdf \
    $(U01_L01)/warmup/main.pdf \
    $(U01_L01)/warmup_key/main.pdf \
    $(U01_L01)/notes/main.pdf \
    $(U01_L01)/notes_key/main.pdf \
    $(U01_L01)/activity/main.pdf \
    $(U01_L01)/activity_key/main.pdf \
    $(U01_L01)/exit_ticket/main.pdf \
    $(U01_L01)/exit_ticket_key/main.pdf \
    $(U01_L01)/homework/main.pdf \
    $(U01_L01)/homework_key/main.pdf

unit01-lesson01-student: $(U01_L01_STUDENT_STAMPS)
	mkdir -p target/compiled
	pdfunite $(U01_L01_STUDENT_PDFS) target/compiled/unit01_lesson01_student.pdf
	@echo "✓  Student packet  →  target/compiled/unit01_lesson01_student.pdf"

unit01-lesson01-full: $(U01_L01_FULL_STAMPS)
	mkdir -p target/compiled
	pdfunite $(U01_L01_FULL_PDFS) target/compiled/unit01_lesson01_full.pdf
	@echo "✓  Full lesson     →  target/compiled/unit01_lesson01_full.pdf"

# ── Lesson 1.1 component lists ────────────────────────────────────────────────
U01_L02 := target/unit01/lesson02

U01_L02_STUDENT_STAMPS := \
    .stamps/unit01/lesson02/cover/main.stamp \
    .stamps/unit01/lesson02/warmup/main.stamp \
    .stamps/unit01/lesson02/notes/main.stamp \
    .stamps/unit01/lesson02/activity/main.stamp \
    .stamps/unit01/lesson02/exit_ticket/main.stamp \
    .stamps/unit01/lesson02/homework/main.stamp

U01_L02_STUDENT_PDFS := \
    $(U01_L02)/cover/main.pdf \
    $(U01_L02)/warmup/main.pdf \
    $(U01_L02)/notes/main.pdf \
    $(U01_L02)/activity/main.pdf \
    $(U01_L02)/exit_ticket/main.pdf \
    $(U01_L02)/homework/main.pdf

U01_L01_FULL_STAMPS := \
    .stamps/unit01/lesson02/main.stamp \
    .stamps/unit01/lesson02/slides/main.stamp \
    .stamps/unit01/lesson02/cover/main.stamp \
    .stamps/unit01/lesson02/warmup/main.stamp \
    .stamps/unit01/lesson02/warmup_key/main.stamp \
    .stamps/unit01/lesson02/notes/main.stamp \
    .stamps/unit01/lesson02/notes_key/main.stamp \
    .stamps/unit01/lesson02/activity/main.stamp \
    .stamps/unit01/lesson02/activity_key/main.stamp \
    .stamps/unit01/lesson02/exit_ticket/main.stamp \
    .stamps/unit01/lesson02/exit_ticket_key/main.stamp \
    .stamps/unit01/lesson02/homework/main.stamp \
    .stamps/unit01/lesson02/homework_key/main.stamp

U01_L02_FULL_PDFS := \
    $(U01_L02)/main.pdf \
    $(U01_L02)/slides/main.pdf \
    $(U01_L02)/cover/main.pdf \
    $(U01_L02)/warmup/main.pdf \
    $(U01_L02)/warmup_key/main.pdf \
    $(U01_L02)/notes/main.pdf \
    $(U01_L02)/notes_key/main.pdf \
    $(U01_L02)/activity/main.pdf \
    $(U01_L02)/activity_key/main.pdf \
    $(U01_L02)/exit_ticket/main.pdf \
    $(U01_L02)/exit_ticket_key/main.pdf \
    $(U01_L02)/homework/main.pdf \
    $(U01_L02)/homework_key/main.pdf

unit01-lesson02-student: $(U01_L02_STUDENT_STAMPS)
	mkdir -p target/compiled
	pdfunite $(U01_L02_STUDENT_PDFS) target/compiled/unit01_lesson02_student.pdf
	@echo "✓  Student packet  →  target/compiled/unit01_lesson02_student.pdf"

unit01-lesson02-full: $(U01_L02_FULL_STAMPS)
	mkdir -p target/compiled
	pdfunite $(U01_L02_FULL_PDFS) target/compiled/unit01_lesson02_full.pdf
	@echo "✓  Full lesson     →  target/compiled/unit01_lesson02_full.pdf"

# ── Cleanup ───────────────────────────────────────────────────────────────────
clean:
	rm -rf target .stamps

distclean: clean
