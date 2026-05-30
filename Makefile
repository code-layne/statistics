.PHONY: all clean distclean shared unit00 unit01

PROJECT_ROOT := $(CURDIR)

TEXINPUTS := .:$(PROJECT_ROOT)/shared//:
GFXINPUTS := .:$(PROJECT_ROOT)//:

LATEXMK = latexmk
LATEXFLAGS = -xelatex \
             -interaction=nonstopmode \
             -halt-on-error \
             -file-line-error

SHARED_MAINS := $(shell find shared -name main.tex)
UNIT00_MAINS := $(shell find unit00_introduction -name main.tex)
UNIT01_MAINS := $(shell find unit01_foundations -name main.tex)

ALL_MAINS := $(SHARED_MAINS) $(UNIT00_MAINS) $(UNIT01_MAINS)

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

clean:
	rm -rf target

distclean:
	rm -rf target