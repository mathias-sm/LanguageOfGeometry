open Graphics
open Interpreter
open Printf
open Lexer
open Lexing
open Generator

let () = Random.self_init ()

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
    let sup = 100000 in
    for i = 1 to sup do
        let oc = open_out (Printf.sprintf "/tmp/enum/%d.LoG" i) in
        let p = generate_next () in
        pp_program oc p ;
        close_out oc
    done ;
    (*open_graph "" ;*)
    (*let string_from_file = file_to_string (Sys.argv.(1)) in*)
    (*match read_program string_from_file with*)
    (*| Some (noise, program) ->*)
        (*pp_program program ;*)
        (*moveto (size_x () / 2) (size_y () / 2) ;*)
        (*interpret program noise ;*)
        (*Unix.sleep 5*)
    (*| None -> failwith("Empty or malformed program")*)
