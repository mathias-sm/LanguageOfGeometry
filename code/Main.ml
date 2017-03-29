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

let loop filename () =
  let inx = open_in filename in
  let lexbuf = Lexing.from_channel inx in
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename };
  let program = parse_with_error lexbuf in
  close_in inx ;
  program

let () =
    open_graph "" ;
    match (loop Sys.argv.(1) ()) with
    | Some program ->
        moveto (size_x () / 2) (size_y () / 2) ;
        interpret program
    | None -> failwith("Empty or malformed program")
