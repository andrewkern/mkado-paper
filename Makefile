# Makefile for mkado-paper
#
# Build targets:
#   make                  - build preprint.pdf (revised manuscript, single-
#                           column article class -- the canonical readable
#                           build for round-1 G3 resubmission)
#   make preprint         - same as `make`
#   make revision         - build main_revision_only.pdf + review-responses.pdf
#                           (line-numbered manuscript with the point-by-point
#                           response document split into a separate PDF; this
#                           is the bundle to submit to the editor)
#   make diff             - build review-diff.pdf (latexdiff between the
#                           pre-revision paper/*.tex on the master branch
#                           and the current revised content)
#   make all-revision     - revision + diff (full submission package)
#   make bioinfo          - build main.pdf via bioinfo.cls. Legacy. The
#                           original submission was drafted against the
#                           Oxford Bioinformatics class; the journal we
#                           are now submitting to is G3, so this target is
#                           kept only for archival comparison and is not
#                           used for any submission deliverable.
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

all: $(PREPRINT_PDF)

preprint: $(PREPRINT_PDF)

$(PREPRINT_PDF): $(PREPRINT_TEX) $(PAPER_TEX) bibliography.bib
	pdflatex $(PREPRINT_BASE)
	-bibtex $(PREPRINT_BASE)
	pdflatex $(PREPRINT_BASE)
	pdflatex $(PREPRINT_BASE)

bioinfo: $(ORIGINAL_PDF)

$(ORIGINAL_PDF): $(ORIGINAL_TEX) $(PAPER_TEX) bibliography.bib bioinfo.cls
	pdflatex $(ORIGINAL_BASE)
	-bibtex $(ORIGINAL_BASE)
	pdflatex $(ORIGINAL_BASE)
	pdflatex $(ORIGINAL_BASE)

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
	  printf '\nERROR: pdftk is required to split the revision PDF.\n'; \
	  printf 'Install with: sudo apt install pdftk-java\n'; \
	  printf '(combined PDF available at $(REVISION_FULL_PDF))\n'; \
	  exit 1; \
	}
	@RESP_START=$$(cat review-responses-pagenum.txt) && \
	RESP_PREV=$$((RESP_START - 1)) && \
	printf 'Splitting PDF: manuscript pp 1-%s, responses pp %s-end\n' "$$RESP_PREV" "$$RESP_START" && \
	pdftk $(REVISION_FULL_PDF) cat 1-$$RESP_PREV output $(REVISION_PDF) && \
	pdftk $(REVISION_FULL_PDF) cat $$RESP_START-end output $(RESPONSES_PDF)

# latexdiff between the pre-revision content and the revision.
# We diff the paper/*.tex contents (not the top-level .tex files), since
# main.tex uses bioinfo.cls and main_revision.tex uses article class --
# latexdiff would choke on the scaffolding mismatch. Both .tex files
# input the same paper/*.tex; we use --flatten to inline them, and we
# fetch the pre-revision paper/*.tex from git (the branch named in
# DIFF_BASE_REF, default `master`).
# Pre-revision submission state. `master` would be wrong here -- once the
# revision merges into master, master IS the revised state, and diffing
# against itself produces no diff. We tag the pre-revision commit instead.
DIFF_BASE_REF ?= submission-v1
DIFF_TMP_DIR  := .diff-orig

diff: $(DIFF_PDF)

review-diff.tex: $(REVISION_TEX) $(PAPER_TEX)
	@command -v latexdiff >/dev/null 2>&1 || { \
	  echo "ERROR: latexdiff is required for the diff target."; \
	  echo "Install with: sudo apt install latexdiff"; \
	  exit 1; \
	}
	@# Materialize pre-revision paper/*.tex into $(DIFF_TMP_DIR)/paper/
	rm -rf $(DIFF_TMP_DIR)
	mkdir -p $(DIFF_TMP_DIR)/paper
	@for f in paper/abstract.tex paper/introduction.tex paper/methods.tex \
	          paper/results.tex paper/acknowledgements.tex paper/funding.tex \
	          paper/supplemental.tex paper/header.tex; do \
	    git show $(DIFF_BASE_REF):$$f > $(DIFF_TMP_DIR)/$$f; \
	done
	@# Build a preprint-shaped scaffold pointing at the pre-revision paper/
	sed 's|{paper/|{$(DIFF_TMP_DIR)/paper/|g' $(PREPRINT_TEX) > preprint-orig.tex
	@# Strip the response block from the revision tex
	sed '/% === Review Responses/,/\\end{document}/d' $(REVISION_TEX) > revision-for-diff.tex
	printf '\\end{document}\n' >> revision-for-diff.tex
	@# Replace \input{review-response-commands} with no-op macro defs --
	@# latexdiff wraps \revpoint{...} in \DIFadd{...}, which interacts
	@# badly with \linelabel; we don't need real back-links in the diff.
	sed -i 's|\\input{review-response-commands}|\\newcommand{\\revpoint}[2]{}\\newcommand{\\revref}{}\\newcommand{\\llabel}[1]{}\\newcommand{\\llname}[1]{}|' revision-for-diff.tex
	@# Drop \linenumbers from the diff so neither side has lineno active.
	sed -i '/^\\linenumbers/d' revision-for-diff.tex
	latexdiff --flatten preprint-orig.tex revision-for-diff.tex > review-diff.tex.tmp
	grep -v '^WARNING:' review-diff.tex.tmp > review-diff.tex
	rm -f preprint-orig.tex revision-for-diff.tex review-diff.tex.tmp
	rm -rf $(DIFF_TMP_DIR)

$(DIFF_PDF): review-diff.tex bibliography.bib
	pdflatex review-diff
	-bibtex review-diff
	pdflatex review-diff
	pdflatex review-diff

all-revision: revision diff

# Brace expansion requires bash, not /bin/sh. Force the shell.
SHELL := /bin/bash

clean:
	rm -f $(ORIGINAL_BASE).{aux,bbl,blg,log,out,pdf,toc}
	rm -f $(PREPRINT_BASE).{aux,bbl,blg,log,out,pdf,toc}
	rm -f $(REVISION_BASE).{aux,bbl,blg,log,out,pdf,toc}
	rm -f $(REVISION_PDF) $(RESPONSES_PDF) $(DIFF_PDF)
	rm -f review-diff.{aux,bbl,blg,log,out,tex}
	rm -f review-responses-pagenum.txt
	rm -f revision-for-diff.tex review-diff.tex.tmp

.PHONY: all preprint bioinfo revision diff all-revision clean
