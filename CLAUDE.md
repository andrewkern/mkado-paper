# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LaTeX manuscript for an applications note describing **MKado**, a Python toolkit for McDonald-Kreitman tests of natural selection. Targeted at *Bioinformatics* (Oxford University Press).

## Build Commands

```bash
make            # Build journal-formatted PDF (main.pdf) using bioinfo.cls
make preprint   # Build preprint PDF (preprint.pdf) using standard article class
make clean      # Remove all build artifacts
```

Build requires `pdflatex` and `bibtex`. Each target runs pdflatex→bibtex→pdflatex→pdflatex.

## Repository Structure

- `main.tex` — Journal entry point (uses `bioinfo.cls`)
- `preprint.tex` — Preprint entry point (stubs out bioinfo.cls commands)
- `paper/` — All manuscript sections as separate `.tex` files:
  - `header.tex` — Shared packages and custom commands (e.g., `\mkado`)
  - `abstract.tex`, `introduction.tex`, `methods.tex`, `results.tex`, `acknowledgements.tex`, `funding.tex`
- `bibliography.bib` — BibTeX references (natbib style)
- `figures/` — PDF and PNG figures (volcano plots, benchmark)
- `bioinfo.cls` — Journal document class (do not edit)
- `natbib.bst` — Bibliography style (do not edit)

## Conventions

- Use `\mkado` (defined in `paper/header.tex`) instead of typing "MKado" directly
- Use `\cref{}` (cleveref) for cross-references to figures/tables
- Use `\citep{}` / `\citet{}` (natbib) for citations
- Both `main.tex` and `preprint.tex` include the same `paper/*.tex` files; edits to content go in `paper/`, not in the entry-point files
