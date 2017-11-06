open Plotter
open Renderer
open Interpreter
open Printf
open Lexer
open Lexing

exception MalformedProgram of string

let _ = Random.self_init ()

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

let _ =
    let internal_c = new_canvas () in
    let program_string = file_to_string  Sys.argv.(1) in
    (try 
        (match read_program program_string with
            | Some (program) ->
                    let cost = costProgram program in
                    let canvas = interpret internal_c program false in
                    output_canvas_png canvas
                        ((Filename.chop_suffix Sys.argv.(1) ".LoG")^".png") ;
                    Printf.printf "Cost = %d\n" cost
            | None -> ())
    with MalformedProgram(error_message) ->
        Printf.printf "%s\n" error_message
    )
