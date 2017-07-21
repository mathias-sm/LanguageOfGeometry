all: js native html

js:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind \
	    -package js_of_ocaml.syntax \
	    -package lwt \
	    -package lwt.log \
	    -package gg \
	    -package vg \
	    -package vg.htmlc \
	    -syntax camlp4o \
	    -plugin-tag "package(js_of_ocaml.ocamlbuild)" Main_js.byte ;\
	    js_of_ocaml +weak.js --opt 3 Main_js.byte \
	    --disable genprim \
	    -o Main.js

test:
	ocamlbuild -use-menhir -tag thread -tag debug -use-ocamlfind \
	    -package gg \
	    -package vg \
	    -package vg.cairo \
	    Main_TEST.native

native:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind \
	    -package gg \
	    -package vg \
	    -package vg.cairo \
	    Main.native

html: index ex

index:
	$(pandoc) whitePaper.md \
	    -A numLines.js \
	    | $(sed) \
	    > index.html
	#$(pandoc) whitePaper.md | $(sed) > index.html

ex:
	./generate_examples_index.sh | \
	    $(pandoc) -A numLines.js \
	    | $(sed) \
	    > examples/index.html

clean:
	rm -Rvf *.byte *.native index.html _build/ examples/index.html Main.js

pandoc = pandoc -s --toc --toc-depth=4 \
	 --from markdown-markdown_in_html_blocks+raw_html+smart \
	 --bibliography ./references.bib \
	 --mathjax \
	 --syntax-definition=LoG_highlight.xml --highlight-style=zenburn \
	 -t html5

sed = sed -e 's/<code /<code contenteditable="" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" /g'
