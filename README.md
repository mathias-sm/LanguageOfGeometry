A Proposal for a Language Of Geometry
=====================================

Stuff will be written here someday. In the meantime, check out the code folder, and its "whitePaper.md", to get a rough idea of what is going on.

Otherwise, I should keep a fairly up to date version [here](http://www.dptinfo.ens-cachan.fr/~msableme/LoG/)

What you need to build this
---------------------------

Mainly:
* `ocaml`
* `opam`, and then you can install `opam install ocamlbuild ocamlfind lwt
  js_of_ocaml js_of_ocaml-ocamlbuild js_of_ocaml-camlp4 js_of_ocaml-lwt menhir
  camlimages` and you're good to go

* I would also recommend installing `core` and `merlin` if you plan to edit
  files.

* `pandoc` - Note that a recent enough version is required as I'm using the
  recently added `--syntax-definition=` option.
