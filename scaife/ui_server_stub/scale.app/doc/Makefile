# Convert Markdown to HTML
# 
# Using make this will convert only the markdown documents that haven't
# been converted yet or have been changed. This can save time if the
# scale.app/public directory is on a shared volume inside a container.
#
# Run "make" (or "make all") to convert to HTML.
#
# Run "make clean" to delete converted files.
#
# <legal></legal>

# supplemental environment
OUT_DIR=../public/doc/scale2
ATTACHMENTS_DIR=./attachments
CONTROL_DIR=./control
IMAGES_DIR=./images
STYLES_DIR=./styles
# STYLES_FILE gets injected into html so relative to documentation root
STYLES_FILE=styles/styles.css
TEMPLATE_FILE=$(CONTROL_DIR)/html.template
LUA_FILE=$(CONTROL_DIR)/md-to-html.lua

PANDOC=pandoc
PANDOC_CMD := $(shell which $(PANDOC))
ifeq (, $(PANDOC_CMD))
$(error "No $(PANDOC) command found in $(PATH)")
endif

# All .md documents in this directory
SRC_DOCS := $(wildcard *.md)

OUT_DOCS := $(SRC_DOCS:.md=.html)
OUT_DOCS := $(patsubst %,$(OUT_DIR)/%,$(OUT_DOCS))

RM=/bin/rm

all : $(OUT_DOCS)

$(OUT_DIR)/%.html : %.md
	$(PANDOC_CMD) \
          -c $(STYLES_FILE) \
          --template=$(TEMPLATE_FILE) \
          -f markdown $< \
          -o $@ \
          --lua-filter=$(LUA_FILE)

.PHONY: clean

clean:
	- $(RM) -f $(OUT_DIR)/*.html
