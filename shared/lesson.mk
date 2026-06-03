# shared/lesson.mk — included by every lesson-level Makefile.
# Auto-detects PROJECT_ROOT, UNIT, and LESSON from CURDIR.

PROJECT_ROOT := $(abspath ../..)
UNIT         := $(notdir $(abspath ..))
LESSON       := $(notdir $(CURDIR))

SHARED_STYS  := $(wildcard $(PROJECT_ROOT)/shared/*.sty)
TEXINPUTS    := $(PROJECT_ROOT)/shared//:
LATEXMK      = latexmk
LATEXFLAGS   = -xelatex \
               -interaction=nonstopmode \
               -halt-on-error \
               -file-line-error

STAMP_DIR    := $(PROJECT_ROOT)/.stamps/$(UNIT)/$(LESSON)
PDF_DIR      := $(PROJECT_ROOT)/target/$(UNIT)/$(LESSON)
COMPILED_DIR := $(PROJECT_ROOT)/target/compiled/$(UNIT)

# ── Component discovery (in pedagogical order) ────────────────────────────────
STUDENT_ORDER := cover warmup notes activity exit_ticket homework
KEY_ORDER     := warmup_key notes_key activity_key exit_ticket_key homework_key

STUDENT_COMPS := $(foreach c,$(STUDENT_ORDER),$(if $(wildcard $(c)/main.tex),$(c)))
KEY_COMPS     := $(foreach c,$(KEY_ORDER),$(if $(wildcard $(c)/main.tex),$(c)))
HAS_SLIDES    := $(if $(wildcard slides/main.tex),slides)
HAS_ROOT_MAIN := $(wildcard main.tex)

# Full order: root, slides, cover, then for each keyed component prefer _key over blank
KEYED_PAIRS   := warmup notes activity exit_ticket homework
COVER_COMP    := $(if $(wildcard cover/main.tex),cover)
KEYED_COMPS   := $(foreach c,$(KEYED_PAIRS),\
                   $(if $(wildcard $(c)_key/main.tex),$(c)_key,\
                   $(if $(wildcard $(c)/main.tex),$(c))))
FULL_COMPS    := $(COVER_COMP) $(KEYED_COMPS)

# ── Stamp and PDF lists ───────────────────────────────────────────────────────
STUDENT_STAMPS := $(foreach c,$(STUDENT_COMPS),$(STAMP_DIR)/$(c)/main.stamp)
STUDENT_PDFS   := $(foreach c,$(STUDENT_COMPS),$(PDF_DIR)/$(c)/main.pdf)

ROOT_STAMP     := $(if $(HAS_ROOT_MAIN),$(STAMP_DIR)/main.stamp)
ROOT_PDF       := $(if $(HAS_ROOT_MAIN),$(PDF_DIR)/main.pdf)
SLIDES_STAMP   := $(if $(HAS_SLIDES),$(STAMP_DIR)/slides/main.stamp)
SLIDES_PDF     := $(if $(HAS_SLIDES),$(PDF_DIR)/slides/main.pdf)

FULL_STAMPS    := $(ROOT_STAMP) $(SLIDES_STAMP) \
                  $(foreach c,$(FULL_COMPS),$(STAMP_DIR)/$(c)/main.stamp)
FULL_PDFS      := $(ROOT_PDF) $(SLIDES_PDF) \
                  $(foreach c,$(FULL_COMPS),$(PDF_DIR)/$(c)/main.pdf)

# ── Targets ───────────────────────────────────────────────────────────────────
.PHONY: all student full clean

all: student full

student: $(STUDENT_STAMPS)
ifneq ($(strip $(STUDENT_PDFS)),)
	@mkdir -p $(COMPILED_DIR)
	pdfunite $(STUDENT_PDFS) $(COMPILED_DIR)/$(LESSON)_student.pdf
	@echo "✓  Student packet → target/compiled/$(UNIT)/$(LESSON)_student.pdf"
else
	@echo "  (no student components in $(UNIT)/$(LESSON))"
endif

full: $(FULL_STAMPS)
ifneq ($(strip $(FULL_PDFS)),)
	@mkdir -p $(COMPILED_DIR)
	pdfunite $(FULL_PDFS) $(COMPILED_DIR)/$(LESSON)_full.pdf
	@echo "✓  Full lesson     → target/compiled/$(UNIT)/$(LESSON)_full.pdf"
else
	@echo "  (no content in $(UNIT)/$(LESSON))"
endif

# ── Pattern rule: compile a component subdirectory ────────────────────────────
$(STAMP_DIR)/%/main.stamp: %/main.tex $(SHARED_STYS)
	@mkdir -p $(dir $@) $(PDF_DIR)/$*
	cd $* && TEXINPUTS="$(TEXINPUTS)" $(LATEXMK) $(LATEXFLAGS) \
		-outdir="$(PDF_DIR)/$*" main.tex
	@touch $@

# ── Rule: compile root-level main.tex ────────────────────────────────────────
$(STAMP_DIR)/main.stamp: main.tex $(SHARED_STYS)
	@mkdir -p $(dir $@) $(PDF_DIR)
	TEXINPUTS="$(TEXINPUTS)" $(LATEXMK) $(LATEXFLAGS) \
		-outdir="$(PDF_DIR)" main.tex
	@touch $@

clean:
	rm -rf $(STAMP_DIR) $(PDF_DIR)
	rm -f $(COMPILED_DIR)/$(LESSON)_student.pdf $(COMPILED_DIR)/$(LESSON)_full.pdf
