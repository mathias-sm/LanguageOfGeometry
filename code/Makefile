all: js native html

js:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind -package js_of_ocaml.graphics -package js_of_ocaml.syntax -syntax camlp4o -plugin-tag "package(js_of_ocaml.ocamlbuild)" Main_js.byte ; js_of_ocaml +graphics.js +weak.js --opt 3 Main_js.byte -o Main.js

native:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind -package js_of_ocaml.graphics -package js_of_ocaml.syntax -syntax camlp4o -plugin-tag "package(js_of_ocaml.ocamlbuild)" Main.native

html: index ex

index:
	$(pandoc) whitePaper.md -o index.html

ex:
	./generate_examples_index.sh | \
	    $(pandoc) > examples/index.html

clean:
	rm -Rvf *.byte *.js *.native index.html _build/ examples/index.html

pandoc = pandoc -s -S --toc --toc-depth=4 \
	 --from markdown-markdown_in_html_blocks+raw_html \
	 --bibliography ./references.bib \
	 -t html5
