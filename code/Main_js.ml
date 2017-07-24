module Html = Dom_html
open Interpreter
open Plotter
open Renderer_js
open Interpreter
open Printf
open Lexer
open Lexing

exception MalformedProgram of string

let showError msg = 
  let errorOutput = Html.getElementById "errorOutput" in
  errorOutput##innerHTML <- Js.string msg

let print_pos lexbuf = 
    let pos = lexbuf.lex_curr_p in
    sprintf "(line %d ; column %d)"
        pos.pos_lnum (pos.pos_cnum - pos.pos_bol)

let parse_with_error lexbuf =
  try Parser.program Lexer.read lexbuf with
  | SyntaxError msg ->
      let pos_string = print_pos lexbuf in
      raise (MalformedProgram
                (sprintf "Error at position %s, %s" pos_string msg))
  | Parser.Error ->
      let pos_string = print_pos lexbuf in
      raise (MalformedProgram (sprintf "Error at position %s\n" pos_string))

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

let drawProgram c =
    let internal_c = new_canvas () in
    let textarea_interne = Html.getElementById "program" in
    let textarea_coerced =
        (Js.Opt.get
            (Html.CoerceTo.textarea textarea_interne))
            (fun () -> failwith "Zut.") in
    let textarea_jstring = textarea_coerced##value in
    let program_string = Js.to_string textarea_jstring in
    let normalOutput = Html.getElementById "normalOutput" in
    normalOutput##innerHTML <- Js.string ("") ;
    (try 
        (match read_program program_string with
            | Some (noise, program) ->
                    showError "" ;
                    normalOutput##innerHTML <-
                        Js.string (Printf.sprintf "Program's cost : %d"
                                    (costProgram program)) ;
                    let canvas =
                        try interpret internal_c program
                        with Interpreter.MalformedProgram(s) -> showError s ;
                        failwith("error")

                    in
                    paint_on_html_canvas canvas c
            | None -> ())
    with MalformedProgram(error_message) -> showError error_message
    ) ;
    Js._true


let start _ =
  Lwt.ignore_result
    (
     let whereToDraw = Html.getElementById "programCanvas" in
     let width = whereToDraw##clientWidth in
     let canvas = create_canvas width (width/2) in
     Dom.appendChild whereToDraw canvas;
     let button = Html.getElementById "interpret" in
     button##onclick <- Dom_html.handler (fun _ -> drawProgram canvas) ;
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
