# Makefile for mkado-paper
#
# Build targets:
#   make                  - build main.pdf (bioinfo.cls submission build)
#   make preprint         - build preprint.pdf (single-column article class)
#   make revision         - build main_revision.pdf + review-responses.pdf
#                           (line-numbered article-class build with the
#                           response document split into a separate PDF)
#   make diff             - build review-diff.pdf (latexdiff between
#                           main.tex and main_revision.tex)
#   make all-revision     - revision + diff
#   make clean            - remove build artifacts
#
# Optional dependencies for revision-related targets:
#   pdftk         - splits the combined PDF at the response page boundary.
#                   Install: `sudo apt install pdftk-java` (Ubuntu)
#   latexdiff     - generates the marked-up diff. Install:
#                   `sudo apt install latexdiff` or via texlive-extra-utils

ORIGINAL_BASE     = main
PREPRINT_BASE     = preprint
REVISION_BASE     = main_revision

ORIGINAL_TEX      = $(ORIGINAL_BASE).tex
PREPRINT_TEX      = $(PREPRINT_BASE).tex
REVISION_TEX      = $(REVISION_BASE).tex

ORIGINAL_PDF      = $(ORIGINAL_BASE).pdf
PREPRINT_PDF      = $(PREPRINT_BASE).pdf
REVISION_FULL_PDF = $(REVISION_BASE).pdf
REVISION_PDF      = $(REVISION_BASE)_only.pdf
RESPONSES_PDF     = review-responses.pdf
DIFF_PDF          = review-diff.pdf

PAPER_TEX = paper/abstract.tex paper/introduction.tex paper/methods.tex \
            paper/results.tex paper/acknowledgements.tex paper/funding.tex \
            paper/supplemental.tex paper/header.tex

REVISION_DEPS = $(REVISION_TEX) $(PAPER_TEX) bibliography.bib \
                review-response-commands.tex review-responses.tex

all: $(ORIGINAL_PDF)

$(ORIGINAL_PDF): $(ORIGINAL_TEX) $(PAPER_TEX) bibliography.bib bioinfo.cls
	pdflatex $(ORIGINAL_BASE)
	-bibtex $(ORIGINAL_BASE)
	pdflatex $(ORIGINAL_BASE)
	pdflatex $(ORIGINAL_BASE)

preprint: $(PREPRINT_PDF)

$(PREPRINT_PDF): $(PREPRINT_TEX) $(PAPER_TEX) bibliography.bib
	pdflatex $(PREPRINT_BASE)
	-bibtex $(PREPRINT_BASE)
	pdflatex $(PREPRINT_BASE)
	pdflatex $(PREPRINT_BASE)

# Revision build: compile once, then split the resulting PDF at the
# page where the response document begins (recorded by LaTeX into
# review-responses-pagenum.txt during compilation).
revision: $(REVISION_PDF) $(RESPONSES_PDF)

$(REVISION_PDF) $(RESPONSES_PDF): $(REVISION_DEPS)
	pdflatex $(REVISION_BASE)
	-bibtex $(REVISION_BASE)
	pdflatex $(REVISION_BASE)
	pdflatex $(REVISION_BASE)
	@command -v pdftk >/dev/null 2>&1 || { \
	  echo ""; \
	  echo "ERROR: pdftk is required to split the revision PDF."; \
	  echo "Install with: sudo apt install pdftk-java"; \
	  echo "(combined PDF available at $(REVISION_FULL_PDF))"; \
	  exit 1; \
	}
	@RESP_START=$$(cat review-responses-pagenum.txt) && \
	RESP_PREV=$$((RESP_START - 1)) && \
	echo "Splitting PDF: manuscript pp 1-$$RESP_PREV, responses pp $$RESP_START-end" && \
	pdftk $(REVISION_FULL_PDF) cat 1-$$RESP_PREV output $(REVISION_PDF) && \
	pdftk $(REVISION_FULL_PDF) cat $$RESP_START-end output $(RESPONSES_PDF)

# latexdiff between the original submission and the revision.
# Strips the response block from the revision before diffing so
# latexdiff does not get confused by the macro-heavy response text.
diff: $(DIFF_PDF)

review-diff.tex: $(ORIGINAL_TEX) $(REVISION_TEX)
	@command -v latexdiff >/dev/null 2>&1 || { \
	  echo "ERROR: latexdiff is required for the diff target."; \
	  echo "Install with: sudo apt install latexdiff"; \
	  exit 1; \
	}
	sed '/% === Review Responses/,/\\end{document}/d' $(REVISION_TEX) > revision-for-diff.tex
	echo '\end{document}' >> revision-for-diff.tex
	latexdiff $(ORIGINAL_TEX) revision-for-diff.tex > review-diff.tex.tmp
	grep -v '^WARNING:' review-diff.tex.tmp > review-diff.tex
	rm -f revision-for-diff.tex review-diff.tex.tmp

$(DIFF_PDF): review-diff.tex $(PAPER_TEX) bibliography.bib bioinfo.cls
	pdflatex review-diff
	-bibtex review-diff
	pdflatex review-diff
	pdflatex review-diff

all-revision: revision diff

clean:
	rm -f $(ORIGINAL_BASE).{aux,bbl,blg,log,out,pdf,toc}
	rm -f $(PREPRINT_BASE).{aux,bbl,blg,log,out,pdf,toc}
	rm -f $(REVISION_BASE).{aux,bbl,blg,log,out,pdf,toc}
	rm -f $(REVISION_PDF) $(RESPONSES_PDF) $(DIFF_PDF)
	rm -f review-diff.{aux,bbl,blg,log,out,tex}
	rm -f review-responses-pagenum.txt
	rm -f revision-for-diff.tex review-diff.tex.tmp

.PHONY: all preprint revision diff all-revision clean
