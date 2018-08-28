FILENAME=presentation

.PHONY: $(FILENAME).pdf all clean

all: $(FILENAME).pdf

$(FILENAME).pdf: $(FILENAME).tex
	latexmk -pdf $(FILENAME).tex

clean:
	latexmk -CA

