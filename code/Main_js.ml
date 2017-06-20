module Html = Dom_html
open Interpreter
open Graphics_js
open Interpreter
open Printf
open Lexer
open Lexing

let print_position outx lexbuf =
  let pos = lexbuf.lex_curr_p in
  fprintf outx "%s:%d:%d" pos.pos_fname
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let parse_with_error lexbuf =
  try Parser.program Lexer.read lexbuf with
  | SyntaxError msg ->
    fprintf stderr "%a: %s\n" print_position lexbuf msg;
    None
  | Parser.Error ->
    fprintf stderr "%a: syntax error\n" print_position lexbuf;
    exit (-1)

let read_program program_string =
  let lexbuf = Lexing.from_string program_string in
  let program = parse_with_error lexbuf in
  program

let file_to_string filename =
    let ic = open_in filename in
    let n = in_channel_length ic in
    let s = Bytes.create n in
    really_input ic s 0 n;
    close_in ic;
    s

let create_canvas w h =
  let d = Html.window##document in
  let c = Html.createCanvas d in
  c##width <- w;
  c##height <- h;
  c

let unsupported_messages () =
  let doc = Html.document in
  let txt = Html.createDiv doc in
  txt##innerHTML <- Js.string
    "Unfortunately, this browser is not supported. \
     Please try again with another browser, \
     such as <a href=\"http://www.mozilla.org/firefox/\">Firefox</a>, \
     <a href=\"http://www.google.com/chrome/\">Chrome</a> or \
     <a href=\"http://www.opera.com/\">Opera</a>.";
  let cell = Html.createDiv doc in
  Dom.appendChild cell txt;
  let table = Html.createDiv doc in
  Dom.appendChild table cell;
  let overlay = Html.createDiv doc in
  overlay##className <- Js.string "overlay";
  Dom.appendChild overlay table;
  Dom.appendChild (doc##body) overlay

let drawProgram truc =
    clear_graph () ;
    let w = size_x ()
    and h = size_y () in
    moveto (w/2) (h/2) ;
    let textarea_interne = Html.getElementById "program" in
    let textarea_coerced =
        (Js.Opt.get
            (Html.CoerceTo.textarea textarea_interne))
            (fun () -> failwith "Zut.") in
    let textarea_jstring = textarea_coerced##value in
    let program_string = Js.to_string textarea_jstring in
    (match read_program program_string with
        | Some ((n1,n2,n3), program) -> interpret program n1 n2 n3
        | None -> failwith("Program NOT OK")) ;
    Js._true


let start _ =
  Lwt.ignore_result
    (
     let doc = Html.document in
     let w = 500 in
     let h = 500 in
     let canvas = create_canvas w h in
     Dom.appendChild doc##body canvas;
     let c = canvas##getContext (Html._2d_) in
     Graphics_js.open_canvas (c##canvas);
     let button = Html.getElementById "interpret" in
     button##onclick <- Dom_html.handler drawProgram ;
     (*drawProgram ();*)
     Lwt.return ());
  Js._false


let start _ =
  try
    ignore (Html.createCanvas (Html.window##document));
    start ()
  with Html.Canvas_not_available ->
    unsupported_messages ();
    Js._false

let _ =
Html.window##onload <- Html.handler start
