all: js native html

js:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind -package js_of_ocaml.graphics -package js_of_ocaml.syntax -syntax camlp4o -plugin-tag "package(js_of_ocaml.ocamlbuild)" Main_js.byte ; js_of_ocaml +graphics.js +weak.js --opt 3 Main_js.byte -o Main.js

native:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind -package js_of_ocaml.graphics -package js_of_ocaml.syntax -syntax camlp4o -plugin-tag "package(js_of_ocaml.ocamlbuild)" Main.native

html:
	pandoc -s -S --toc -c style.css whitePaper.md --from markdown-markdown_in_html_blocks+raw_html -t html5 -o index.html
	./generate_examples_index.sh | pandoc -s -S --toc -c ../style.css --from markdown-markdown_in_html_blocks+raw_html -t html5 > examples/index.html

clean:
	rm -Rvf *.byte *.js *.native index.html _build/ examples/index.html
