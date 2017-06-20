js:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind -package js_of_ocaml.graphics -package js_of_ocaml.syntax -syntax camlp4o -plugin-tag "package(js_of_ocaml.ocamlbuild)" Main_js.byte ; js_of_ocaml +graphics.js +weak.js --opt 3 Main_js.byte -o Main.js

native:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind -package js_of_ocaml.graphics -package js_of_ocaml.syntax -syntax camlp4o -plugin-tag "package(js_of_ocaml.ocamlbuild)" Main.native

html:
	pandoc -s -S --toc -c style.css whitePaper.md -t html5 -o index.html

clean:
	rm -Rv *.byte *.js *.native _build/
