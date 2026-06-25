# shared/unit.mk — included by every unit-level Makefile.
# Auto-detects PROJECT_ROOT and UNIT from CURDIR.

PROJECT_ROOT := $(abspath ..)
UNIT         := $(notdir $(CURDIR))
COMPILED_DIR := $(PROJECT_ROOT)/target/compiled
SHARED_STYS  := $(wildcard $(PROJECT_ROOT)/shared/*.sty)
TEXINPUTS    := $(PROJECT_ROOT)/shared//:
LATEXMK      = latexmk
LATEXFLAGS   = -xelatex \
               -interaction=nonstopmode \
               -halt-on-error \
               -file-line-error

# Auto-discover lessons that have a Makefile, in sorted order.
LESSONS := $(patsubst %/Makefile,%,$(sort $(wildcard lesson*/Makefile)))

# Optional unit-level bookend components.
HAS_UNIT_COVER      := $(wildcard unit_cover/main.tex)
HAS_SAMPLE_TEST     := $(wildcard sample_test/main.pdf)
HAS_SAMPLE_TEST_KEY := $(wildcard sample_test_key/main.pdf)
HAS_UNIT_STUDENT_TEX := $(wildcard $(UNIT)_student.tex)
HAS_UNIT_FULL_TEX    := $(wildcard $(UNIT)_full.tex)

UNIT_COVER_PDF      := $(if $(HAS_UNIT_COVER),$(COMPILED_DIR)/$(UNIT)/unit_cover.pdf)
SAMPLE_TEST_PDF     := $(if $(HAS_SAMPLE_TEST),$(COMPILED_DIR)/$(UNIT)/sample_test.pdf)
SAMPLE_TEST_KEY_PDF := $(if $(HAS_SAMPLE_TEST_KEY),$(COMPILED_DIR)/$(UNIT)/sample_test_key.pdf)

.PHONY: all student full clean $(LESSONS) _unit_cover _sample_test _sample_test_key

all: $(LESSONS)

$(LESSONS):
	$(MAKE) -C $@

# ── Optional bookend rules ────────────────────────────────────────────────────

_unit_cover:
ifdef HAS_UNIT_COVER
	@mkdir -p $(COMPILED_DIR)/$(UNIT)
	cd unit_cover && TEXINPUTS="$(PROJECT_ROOT)/shared//:" \
	    latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error \
	    -outdir="$(PROJECT_ROOT)/target/$(UNIT)/unit_cover" main.tex
	cp $(PROJECT_ROOT)/target/$(UNIT)/unit_cover/main.pdf $(UNIT_COVER_PDF)
	@echo "✓  Unit cover        → target/compiled/$(UNIT)/unit_cover.pdf"
endif

_sample_test:
ifdef HAS_SAMPLE_TEST
	@mkdir -p $(COMPILED_DIR)/$(UNIT)
	cp sample_test/main.pdf $(SAMPLE_TEST_PDF)
	@echo "✓  Sample test       → target/compiled/$(UNIT)/sample_test.pdf"
endif

_sample_test_key:
ifdef HAS_SAMPLE_TEST_KEY
	@mkdir -p $(COMPILED_DIR)/$(UNIT)
	cp sample_test_key/main.pdf $(SAMPLE_TEST_KEY_PDF)
	@echo "✓  Sample test key   → target/compiled/$(UNIT)/sample_test_key.pdf"
endif

# ── student / full targets ────────────────────────────────────────────────────

student: _unit_cover $(LESSONS) _sample_test
	@for l in $(LESSONS); do $(MAKE) -C $$l student || exit 1; done
	@mkdir -p $(COMPILED_DIR)/$(UNIT) $(COMPILED_DIR)
ifdef HAS_UNIT_STUDENT_TEX
	TEXINPUTS="$(TEXINPUTS)" $(LATEXMK) $(LATEXFLAGS) \
		-outdir="$(COMPILED_DIR)" $(UNIT)_student.tex
	@echo "✓  Unit student packet → target/compiled/$(UNIT)_student.pdf"
else
	@lesson_pdfs=$$(ls $(COMPILED_DIR)/$(UNIT)/lesson*_student.pdf 2>/dev/null | sort); \
	all_pdfs="$(UNIT_COVER_PDF) $$lesson_pdfs $(SAMPLE_TEST_PDF)"; \
	all_pdfs=$$(echo $$all_pdfs | tr ' ' '\n' | grep -v '^$$'); \
	if [ -n "$$all_pdfs" ]; then \
	  pdfunite $$all_pdfs $(COMPILED_DIR)/$(UNIT)_student.pdf; \
	  echo "✓  Unit student packet → target/compiled/$(UNIT)_student.pdf"; \
	else \
	  echo "  (no student PDFs found for $(UNIT))"; \
	fi
endif

full: _unit_cover $(LESSONS) _sample_test _sample_test_key
	@for l in $(LESSONS); do $(MAKE) -C $$l full || exit 1; done
	@mkdir -p $(COMPILED_DIR)/$(UNIT) $(COMPILED_DIR)
ifdef HAS_UNIT_FULL_TEX
	TEXINPUTS="$(TEXINPUTS)" $(LATEXMK) $(LATEXFLAGS) \
		-outdir="$(COMPILED_DIR)" $(UNIT)_full.tex
	@echo "✓  Unit full packet    → target/compiled/$(UNIT)_full.pdf"
else
	@lesson_pdfs=$$(ls $(COMPILED_DIR)/$(UNIT)/lesson*_full.pdf 2>/dev/null | sort); \
	all_pdfs="$(UNIT_COVER_PDF) $$lesson_pdfs $(SAMPLE_TEST_PDF) $(SAMPLE_TEST_KEY_PDF)"; \
	all_pdfs=$$(echo $$all_pdfs | tr ' ' '\n' | grep -v '^$$'); \
	if [ -n "$$all_pdfs" ]; then \
	  pdfunite $$all_pdfs $(COMPILED_DIR)/$(UNIT)_full.pdf; \
	  echo "✓  Unit full packet    → target/compiled/$(UNIT)_full.pdf"; \
	else \
	  echo "  (no full PDFs found for $(UNIT))"; \
	fi
endif

clean:
	@for l in $(LESSONS); do $(MAKE) -C $$l clean; done
	rm -rf $(PROJECT_ROOT)/target/$(UNIT)/unit_cover
	rm -f $(UNIT_COVER_PDF) $(SAMPLE_TEST_PDF) $(SAMPLE_TEST_KEY_PDF)
	rm -f $(COMPILED_DIR)/$(UNIT)_student.pdf $(COMPILED_DIR)/$(UNIT)_full.pdf
