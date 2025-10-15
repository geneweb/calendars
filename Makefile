js:
	dune build js/calendars_js.bc.js

test:
	dune build @runtest

clean:
	dune clean

.PHONY: js test clean
