dune-js:
	dune build js/calendars_js.bc.js

js:
	ocamlfind ocamlc -package calendars -package js_of_ocaml -package js_of_ocaml-ppx -linkpkg -o calendars_js.bc js/calendars_js.ml
	js_of_ocaml calendars_js.bc

.PHONY: dune-js js
