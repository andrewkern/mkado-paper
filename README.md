# MKado Paper

Manuscript source for the MKado applications note (G3, MS G3-2026-406681).

## Building

Requires `pdflatex` + `bibtex`. The `revision` and `diff` targets also need `pdftk` and `latexdiff` (`apt install pdftk-java latexdiff`).

| Command | Produces |
|---|---|
| `make` | `preprint.pdf` — revised manuscript, single-column |
| `make revision` | `main_revision_only.pdf` (line-numbered) + `review-responses.pdf` |
| `make diff` | `review-diff.pdf` — latexdiff vs `master` |
| `make all-revision` | `revision` + `diff` (full G3 submission package) |
| `make bioinfo` | `main.pdf` via legacy bioinfo.cls (archival only) |
| `make clean` | remove build artifacts |
