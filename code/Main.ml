open Graphics
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

let () =
    open_graph "" ;
    (*let string_from_file = file_to_string (Sys.argv.(1)) in*)
    let test = "Set(1.,0.01) ; Integrate(10000.) { }" in
    match read_program test with
    | Some program ->
        moveto (size_x () / 2) (size_y () / 2) ;
        interpret program
    | None -> failwith("Empty or malformed program")
