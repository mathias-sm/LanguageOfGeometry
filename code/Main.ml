open Graphics
open Interpreter
open Printf
open Lexer
open Lexing
open Generator
open Images

let () = Random.self_init ()

let memory : (color array array, int) Hashtbl.t = Hashtbl.create 10007

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
    set_line_width 3 ;
    auto_synchronize false ;
    display_mode false ;
    remember_mode true ;
    let sup = 1000000 in
    for i = 1 to sup do
        let p = generate_next () in
        clear_graph () ;
        moveto (size_x () / 2) (size_y () / 2) ;
        try begin
            interpret p 0. ;
            let image = get_image 0 0 (size_x ()) (size_y ()) in
            let result = dump_image image in
            if Hashtbl.mem memory result then begin
                Hashtbl.replace memory result ((Hashtbl.find memory result) + 1)
            end
            else begin
                Hashtbl.add memory result 1 ;
                Printf.printf "%d is new !" i ;
                print_newline () ;
                let oc = open_out (Printf.sprintf "/tmp/enum/%d.LoG" i) in
                Png.save
                    (Printf.sprintf "/tmp/enum/%d.png" i) []
                    (Rgb24 (Graphic_image.image_of image)) ;
                pp_program oc p ;
                close_out oc
            end
        end
        with MalformedProgram(s) -> ()
    done ;
    close_graph ()
