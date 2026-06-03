# shared/unit.mk — included by every unit-level Makefile.
# Auto-detects PROJECT_ROOT and UNIT from CURDIR.

PROJECT_ROOT := $(abspath ..)
UNIT         := $(notdir $(CURDIR))
COMPILED_DIR := $(PROJECT_ROOT)/target/compiled

# Auto-discover lessons that have a Makefile, in sorted order.
LESSONS := $(patsubst %/Makefile,%,$(sort $(wildcard lesson*/Makefile)))

.PHONY: all student full clean $(LESSONS)

all: $(LESSONS)

$(LESSONS):
	$(MAKE) -C $@

student:
	@for l in $(LESSONS); do $(MAKE) -C $$l student || exit 1; done
	@mkdir -p $(COMPILED_DIR)
	@pdfs=$$(ls $(COMPILED_DIR)/$(UNIT)/lesson*_student.pdf 2>/dev/null | sort); \
	if [ -n "$$pdfs" ]; then \
	  pdfunite $$pdfs $(COMPILED_DIR)/$(UNIT)_student.pdf; \
	  echo "✓  Unit student packet → target/compiled/$(UNIT)_student.pdf"; \
	else \
	  echo "  (no lesson student PDFs found for $(UNIT))"; \
	fi

full:
	@for l in $(LESSONS); do $(MAKE) -C $$l full || exit 1; done
	@mkdir -p $(COMPILED_DIR)
	@pdfs=$$(ls $(COMPILED_DIR)/$(UNIT)/lesson*_full.pdf 2>/dev/null | sort); \
	if [ -n "$$pdfs" ]; then \
	  pdfunite $$pdfs $(COMPILED_DIR)/$(UNIT)_full.pdf; \
	  echo "✓  Unit full packet    → target/compiled/$(UNIT)_full.pdf"; \
	else \
	  echo "  (no lesson full PDFs found for $(UNIT))"; \
	fi

clean:
	@for l in $(LESSONS); do $(MAKE) -C $$l clean; done
	rm -f $(COMPILED_DIR)/$(UNIT)_student.pdf $(COMPILED_DIR)/$(UNIT)_full.pdf
