.PHONY: all clean distclean unit01 unit02 units unit01-pdf unit02-pdf

PROJECT_ROOT := $(CURDIR)

TEXINPUTS := .:$(PROJECT_ROOT)/shared//:
GFXINPUTS := .:$(PROJECT_ROOT)//:

LATEXMK = latexmk
LATEXFLAGS = -xelatex \
             -interaction=nonstopmode \
             -halt-on-error \
             -file-line-error

SHARED_MAINS := $(shell find shared -name main.tex)
UNIT01_MAINS := $(shell find unit01 -name main.tex | sort)
UNIT02_MAINS := $(shell find unit02 -name main.tex | sort)

ALL_MAINS := $(SHARED_MAINS) $(UNIT01_MAINS) $(UNIT02_MAINS)

UNIT01_PDFS := $(patsubst %.tex,target/%.pdf,$(UNIT01_MAINS))
UNIT02_PDFS := $(patsubst %.tex,target/%.pdf,$(UNIT02_MAINS))

all:
	@for tex in $(ALL_MAINS); do \
		dir=$$(dirname $$tex); \
		out="$(PROJECT_ROOT)/target/$$dir"; \
		mkdir -p "$$out"; \
		echo "Building $$tex -> $$out"; \
		cd "$$dir" && \
		TEXINPUTS="$(TEXINPUTS)" \
		GFXINPUTS="$(GFXINPUTS)" \
		$(LATEXMK) $(LATEXFLAGS) -outdir="$$out" main.tex; \
		cd "$(PROJECT_ROOT)"; \
	done

units: unit01-pdf unit02-pdf

unit01-pdf: all
	mkdir -p target/compiled
	pdfunite $(UNIT01_PDFS) target/compiled/unit01.pdf

unit02-pdf: all
	mkdir -p target/compiled
	pdfunite $(UNIT02_PDFS) target/compiled/unit02.pdf

clean:
	rm -rf target

distclean:
	rm -rf target