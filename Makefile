setup:
	npm --registry http://registry.npmjs.org install

build:
	npm run build

test: build
	npm run test

.PHONY: setup build test
