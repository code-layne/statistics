# shared/lesson.mk — included by every lesson-level Makefile.
# Auto-detects PROJECT_ROOT, UNIT, and LESSON from CURDIR.
#
# A component subdirectory may provide EITHER:
#   - main.tex  → compiled with latexmk to target/.../<comp>/main.pdf, or
#   - main.pdf  → a prefab PDF, used as-is straight from the source tree.
# Either form is discovered and merged into the packet by pdfunite.

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

# ── Component helpers ─────────────────────────────────────────────────────────
# A component "exists" if its directory holds a main.tex or a prefab main.pdf.
#   comp-present $1 → the dir name if usable, else empty
#   comp-pdf     $1 → the PDF to feed pdfunite: compiled target if main.tex,
#                     otherwise the source main.pdf used as-is
#   comp-stamp   $1 → a build stamp ONLY for tex components (prefab PDFs don't compile)
comp-present = $(if $(or $(wildcard $1/main.tex),$(wildcard $1/main.pdf)),$1)
comp-pdf     = $(if $(wildcard $1/main.tex),$(PDF_DIR)/$1/main.pdf,$1/main.pdf)
comp-stamp   = $(if $(wildcard $1/main.tex),$(STAMP_DIR)/$1/main.stamp)

# ── Component discovery (in pedagogical order) ────────────────────────────────
STUDENT_ORDER := cover warmup notes activity exit_ticket homework
KEYED_PAIRS   := warmup notes activity exit_ticket homework

STUDENT_COMPS := $(foreach c,$(STUDENT_ORDER),$(call comp-present,$(c)))
COVER_COMP    := $(call comp-present,cover)

# Full version: prefer <c>_key over the blank <c>; cover has no key.
KEYED_COMPS   := $(foreach c,$(KEYED_PAIRS),\
                   $(or $(call comp-present,$(c)_key),$(call comp-present,$(c))))
FULL_COMPS    := $(COVER_COMP) $(KEYED_COMPS)

# Root lesson plan and slides may also be prefab PDFs.
HAS_ROOT      := $(or $(wildcard main.tex),$(wildcard main.pdf))
ROOT_STAMP    := $(if $(wildcard main.tex),$(STAMP_DIR)/main.stamp)
ROOT_PDF      := $(if $(HAS_ROOT),$(if $(wildcard main.tex),$(PDF_DIR)/main.pdf,main.pdf))

HAS_SLIDES    := $(call comp-present,slides)
SLIDES_STAMP  := $(call comp-stamp,slides)
SLIDES_PDF    := $(if $(HAS_SLIDES),$(call comp-pdf,slides))

# ── Stamp and PDF lists ───────────────────────────────────────────────────────
# Stamps drive compilation (tex only); PDF lists drive the pdfunite merge.
STUDENT_STAMPS := $(foreach c,$(STUDENT_COMPS),$(call comp-stamp,$(c)))
STUDENT_PDFS   := $(foreach c,$(STUDENT_COMPS),$(call comp-pdf,$(c)))

FULL_STAMPS    := $(ROOT_STAMP) $(SLIDES_STAMP) \
                  $(foreach c,$(FULL_COMPS),$(call comp-stamp,$(c)))
FULL_PDFS      := $(ROOT_PDF) $(SLIDES_PDF) \
                  $(foreach c,$(FULL_COMPS),$(call comp-pdf,$(c)))

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

# ── Pattern rule: compile a component subdirectory (tex components only) ───────
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