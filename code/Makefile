all: js generate html

js:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind \
	    -package js_of_ocaml.syntax \
	    -package lwt \
	    -package lwt.log \
	    -package gg \
	    -package vg \
	    -package vg.htmlc \
	    -syntax camlp4o \
	    Main_js.byte ;\
	    js_of_ocaml +weak.js --opt 3 Main_js.byte \
	    --disable genprim \
	    -o Main.js

test:
	ocamlbuild -use-menhir -tag thread -tag debug -use-ocamlfind \
	    -package gg \
	    -package vg \
	    -package vg.cairo \
	    Main_TEST.native

generate:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind \
	    -package camlimages \
	    -package camlimages.png \
	    -package gg \
	    -package vg \
	    -package vg.cairo \
	    Main_generate.native

html: index ex sandbox

index:
	$(pandoc) whitePaper.md -o index.html

introduction:
	$(pandoc) introduction.md -o index.html

sandbox:
	$(pandoc) sandbox.md -o sandbox.html

ex:
	./generate_examples_index.sh | \
	    $(pandoc) -o examples/index.html

clean:
	rm -Rvf *.byte *.native index.html _build/ examples/index.html Main.js

pandoc = pandoc -s --toc --toc-depth=4 \
	 --from markdown-markdown_in_html_blocks+raw_html+smart+fenced_code_attributes \
	 --bibliography ./references.bib \
	 --mathjax \
	 --syntax-definition=LoG_highlight.xml --highlight-style=zenburn \
	 -A numLines.js \
	 -t html5
