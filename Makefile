DATA=
FIGURES=
# To add a new illustration, add a line for the corresponding figure name
# here (use hyphens to separate words, not underscores). Then, define
# the corresponding function/command in illustrations.py, making
# sure that it writes out the corresponding SVG file. The Makefile will
# take care of the rest.
# NB: ensure that any additional static files that must be stored in
# git are put in the illustrations/assets directory.
ILLUSTRATIONS=\
	illustrations/ancestry-resolution.pdf \
	illustrations/simplification.pdf \
	illustrations/arg-in-pedigree.pdf \
	illustrations/inference.pdf \
	illustrations/cell-lines.pdf \
	illustrations/simplification-with-edges.pdf \

all: paper.pdf

paper.pdf: paper.tex paper.bib ${DATA} ${FIGURES} ${ILLUSTRATIONS}
	pdflatex -shell-escape paper.tex
	bibtex paper
	pdflatex paper.tex
	pdflatex paper.tex

inference_inputs: \
	examples/Kreitman_SNP.samples \
	examples/Kreitman_SNP.matrix \
	examples/Kreitman_SNP.sites

inference_outputs: \
	inference_inputs \
	examples/Kreitman_SNP_tsinfer.trees \
	examples/Kreitman_SNP_kwarg.trees \
	examples/Kreitman_SNP_argweaver.trees \

examples/Kreitman_SNP.samples: make_example_inputs.py
	python3 	make_example_inputs.py tsinfer-input

examples/Kreitman_SNP.kwarg: make_example_inputs.py
	python3 	make_example_inputs.py kwarg-input

examples/Kreitman_SNP.sites: make_example_inputs.py
	python3 	make_example_inputs.py argweaver-input

examples/Kreitman_SNP_tsinfer.trees: make_example_outputs.py
	python3 	make_example_outputs.py run-tsinfer

examples/Kreitman_SNP_kwarg.trees: make_example_outputs.py
	python3 	make_example_outputs.py run-kwarg

examples/Kreitman_SNP_argweaver.trees: make_example_outputs.py
	python3 	make_example_outputs.py run-argweaver

illustrations/%.svg: illustrations.py
	python3 illustrations.py $*

%.pdf : %.svg
	# Needs inkscape >= 1.0
	inkscape --export-type="pdf" $<

paper.ps: paper.dvi
	dvips paper

paper.dvi: paper.tex paper.bib
	latex paper.tex
	bibtex paper
	latex paper.tex
	latex paper.tex

.PHONY: spellcheck
spellcheck: aspell.conf
	aspell --conf ./aspell.conf --check paper.tex

clean:
	rm -f *.pdf
	rm -f illustrations/*.pdf
	rm -f illustrations/*.svg
	rm -f *.log *.dvi *.aux
	rm -f *.blg *.bbl

mrproper: clean
	rm -f *.ps *.pdf
