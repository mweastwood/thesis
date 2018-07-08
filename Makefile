FILENAME=eastwood_michael_2019
BIBER=/scr2/mweastwood/usr/bin/biber

.PHONY: $(FILENAME).pdf all clean

all: $(FILENAME).pdf

format:
	$(BIBER) --tool --configfile=biber.conf --collate --output-align --output-indent=4 --fixinits -O thesis.bib thesis.bib

$(FILENAME).pdf: $(FILENAME).tex
	latexmk -pdf $(FILENAME).tex

clean:
	latexmk -CA

