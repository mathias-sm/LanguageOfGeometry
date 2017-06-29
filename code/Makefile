all: js native html

js:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind \
	    -package js_of_ocaml.graphics \
	    -package js_of_ocaml.syntax \
	    -package lwt \
	    -package js_of_ocaml-lwt.logger \
	    -package lwt.log \
	    -syntax camlp4o \
	    -plugin-tag "package(js_of_ocaml.ocamlbuild)" Main_js.byte ;\
	    js_of_ocaml +graphics.js +weak.js --opt 3 Main_js.byte \
	    -o Main.js

native:
	ocamlbuild -use-menhir -tag thread -use-ocamlfind \
	    -package js_of_ocaml.graphics \
	    -package js_of_ocaml.syntax \
	    -syntax camlp4o -plugin-tag "package(js_of_ocaml.ocamlbuild)" Main.native

html: index ex

index:
	$(pandoc) whitePaper.md \
	    -A numLines.js \
	    --highlight-style zenburn \
	    | $(sed) \
	    > index.html
	#$(pandoc) whitePaper.md | $(sed) > index.html

ex:
	./generate_examples_index.sh | \
	    $(pandoc) -A numLines.js \
	    | $(sed) \
	    > examples/index.html

clean:
	rm -Rvf *.byte *.js *.native index.html _build/ examples/index.html

pandoc = pandoc -s --toc --toc-depth=4 \
	 --from markdown-markdown_in_html_blocks+raw_html+smart \
	 --bibliography ./references.bib \
	 --syntax-definition=LoG_highlight.xml --highlight-style=zenburn \
	 -t html5

sed = sed -e 's/<code /<code contenteditable="" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" /g'
