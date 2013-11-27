
COFFEE=node_modules/.bin/coffee --js

SRCDIR = src
SRC = $(shell find $(SRCDIR) -type f -name '*.coffee')
LIBDIR = lib
LIB = $(SRC:$(SRCDIR)/%.coffee=$(LIBDIR)/%.js)

$(LIBDIR)/%.js: $(SRCDIR)/%.coffee
	@mkdir -p "$(@D)"
	$(COFFEE) <"$<" >"$@"

build: $(LIB)

setup:
	npm --registry http://registry.npmjs.org install

all: setup clean

.PHONY: setup build all
