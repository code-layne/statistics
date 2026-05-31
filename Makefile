.PHONY: all clean distclean units unit01-pdf unit02-pdf \
        lesson01-full lesson01-student

PROJECT_ROOT := $(CURDIR)

TEXINPUTS := .:$(PROJECT_ROOT)/shared//:
GFXINPUTS := .:$(PROJECT_ROOT)//:

LATEXMK    = latexmk
LATEXFLAGS = -xelatex \
             -interaction=nonstopmode \
             -halt-on-error \
             -file-line-error

# ── Source discovery ──────────────────────────────────────────────────────────
SHARED_MAINS := $(shell find shared   -name main.tex 2>/dev/null)
UNIT01_MAINS := $(shell find unit01   -name main.tex 2>/dev/null | sort)
UNIT02_MAINS := $(shell find unit02   -name main.tex 2>/dev/null | sort)
ALL_MAINS    := $(SHARED_MAINS) $(UNIT01_MAINS) $(UNIT02_MAINS)

# ── Output PDF paths (mirrors source tree under target/) ─────────────────────
# Each unit01/lessonXX/.../main.tex → target/unit01/lessonXX/.../main.pdf
UNIT01_PDFS  := $(patsubst %.tex, target/%.pdf, $(UNIT01_MAINS))
UNIT02_PDFS  := $(patsubst %.tex, target/%.pdf, $(UNIT02_MAINS))

# ── Build all sources with latexmk ────────────────────────────────────────────
all:
	@for tex in $(ALL_MAINS); do \
		dir=$$(dirname $$tex); \
		out="$(PROJECT_ROOT)/target/$$dir"; \
		mkdir -p "$$out"; \
		echo "▶  $$tex  →  $$out"; \
		cd "$$dir" && \
		TEXINPUTS="$(TEXINPUTS)" \
		GFXINPUTS="$(GFXINPUTS)" \
		$(LATEXMK) $(LATEXFLAGS) -outdir="$$out" main.tex; \
		cd "$(PROJECT_ROOT)"; \
	done

# ── Unit bundles ──────────────────────────────────────────────────────────────
units: unit01-pdf unit02-pdf

unit01-pdf: all
	mkdir -p target/compiled
	pdfunite $(UNIT01_PDFS) target/compiled/unit01.pdf

unit02-pdf: all
	mkdir -p target/compiled
	pdfunite $(UNIT02_PDFS) target/compiled/unit02.pdf

# ── Lesson 1.1 bundles ────────────────────────────────────────────────────────
#
# Depends on `all` so every component is up to date before merging.
# PDFs are read from target/unit01/lesson01/<component>/main.pdf.
#
# lesson01-student  cover → warmup → notes → activity → exit* → homework
#                   (* add exit ticket path once that directory exists)
#
# lesson01-full     lesson plan → slides → all student docs interleaved
#                   with their keys

L01 := target/unit01/lesson01

L01_STUDENT_PDFS := \
    $(L01)/cover/main.pdf \
    $(L01)/warmup/main.pdf \
    $(L01)/notes/main.pdf \
    $(L01)/activity/main.pdf \
    $(L01)/homework/main.pdf

# Add $(L01)/exit/main.pdf above (before homework) once that directory exists.

L01_FULL_PDFS := \
    $(L01)/main.pdf \
    $(L01)/slides/main.pdf \
    $(L01)/cover/main.pdf \
    $(L01)/warmup/main.pdf \
    $(L01)/warmup_key/main.pdf \
    $(L01)/notes/main.pdf \
    $(L01)/notes_key/main.pdf \
    $(L01)/activity/main.pdf \
    $(L01)/activity_key/main.pdf \
    $(L01)/homework/main.pdf \
    $(L01)/homework_key/main.pdf

# Add $(L01)/exit/main.pdf and $(L01)/exit_key/main.pdf above once built.

lesson01-student: all
	mkdir -p target/compiled
	pdfunite $(L01_STUDENT_PDFS) target/compiled/unit01_lesson01_student.pdf
	@echo "✓  Student packet  →  target/compiled/unit01_lesson01_student.pdf"

lesson01-full: all
	mkdir -p target/compiled
	pdfunite $(L01_FULL_PDFS) target/compiled/unit01_lesson01_full.pdf
	@echo "✓  Full lesson     →  target/compiled/unit01_lesson01_full.pdf"

# ── Cleanup ───────────────────────────────────────────────────────────────────
clean:
	rm -rf target

distclean: clean