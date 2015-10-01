.PHONY: sync

PROJ_ROOT=$(PWD)
DOC_PATH=$(PROJ_ROOT)/doc
OUT_PATH=$(PROJ_ROOT)/out
BUILD_PATH=$(PROJ_ROOT)/build

LATEX_ENGINE=xelatex

PANDOC_OPTS=--from=markdown\
			--to=latex\
			--smart\
			--chapters

XELATEX_OPTS=

# := is expanded once, see https://www.gnu.org/software/make/manual/html_node/Flavors.html#Flavors
MD_FILES := $(wildcard $(DOC_PATH)/chapter*.md | sort)

all: thesis.pdf

sync:
	rsync --quiet --recursive $(DOC_PATH)/ $(BUILD_PATH)

# https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html
text.tex: $(MD_FILES)
	pandoc --latex-engine=$(LATEX_ENGINE) $(PANDOC_OPTS) $^ --output $(DOC_PATH)/$@

# Setting `-output-directory` to prevent the cruft won't help,
# because biber and makeglossaries don't have that flag.
# The current solution is to `rsync` the document into a temporary build folder
# and to cp the generated `pdf` into the output folder.
# This works very well and you can `rm -r` the content of build folder with all the cruft.
thesis.pdf: text.tex sync
	cd $(BUILD_PATH) &&\
	xelatex $(XELATEX_OPTS) -no-pdf $(BUILD_PATH)/thesis &&\
	biber $(BUILD_PATH)/thesis &&\
	xelatex $(XELATEX_OPTS) $(BUILD_PATH)/thesis &&\
	cp $(BUILD_PATH)/thesis.pdf $(OUT_PATH)
	#makeglossaries $(BUILD_PATH)/glossary &&

clean:
	rm -f $(DOC_PATH)/text.tex
	rm -f $(OUT_PATH)/thesis.pdf
# I could use the $(BUILD_PATH) variable at this point, but if it expands to "" we will be really sad and I am a coward using rm -r with variable arguments
	rm -r build/*