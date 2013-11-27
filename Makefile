
src_FILES	= $(shell find src -type f -name '*.coffee')
lib_FILES	= $(src_FILES:src/%.coffee=lib/%.js)

build: $(lib_FILES)

lib/%.js: src/%.coffee
	@mkdir -p "$(@D)"
	./node_modules/.bin/coffee --js <"$<" >"$@"

setup:
	npm --registry http://registry.npmjs.org install

test:
	./node_modules/.bin/mocha --compilers coffee:coffee-script-redux/register

.PHONY: setup test build
