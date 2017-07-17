open Graphics
open Plotter
open Interpreter
open Printf
(*open Generator*)
open Images
open Unix

(*
let memory : (color array array, int) Hashtbl.t = Hashtbl.create 10007

let () =
    open_graph "" ;
    set_line_width 4 ;
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
                let prev = Hashtbl.find memory result in
                Hashtbl.replace memory result (prev + 1)
            end
            else begin
                Hashtbl.add memory result 1 ;
                Printf.printf "%d is new !" i ;
                print_newline () ;
                let oc = open_out (Printf.sprintf "/tmp/enum_changedOrder/%d.LoG" i) in
                Png.save
                    (Printf.sprintf "/tmp/enum_changedOrder/%d.png" i) []
                    (Rgb24 (Graphic_image.get_image 0 0 (size_x ()) (size_y
                    ()))) ;
                pp_program oc p ;
                close_out oc
            end
        end
        with MalformedProgram(s) -> ()
    done ;
    close_graph ()

let square : program =
    Repeat(Some(Double(Unit)),Concat(Integrate(Some(Half(Unit)),None,(None,None,None,None)),Turn(None)))

let circle : program =
    Integrate(None,None,(None,None,Some(Unit),None))

let sideBySide : program =
    Concat(square,Concat(Integrate(None,Some false,(None,None,None,None)),circle))

 let zigzag : program =
    (*Concat( *)
        (*Define("turn", Unit),*)
        (*Repeat(Some(Double(Double(Double(Unit)))),*)
            (*Concat( *)
                (*Integrate(Some(Half(Half(Unit))),None,(None,None,None,None)),*)
                (*Concat( *)
                    (*Turn(Some(Name("turn"))),*)
                    (*Define("turn", Oppos(Name("turn")))*)
                (*)*)
            (*)*)
        (*)) *)


let oneMore = Concat(sideBySide, sideBySide)

let () =
    open_graph "" ;
    set_line_width 0 ;
    Plotter.moveto (middle_x ()) (middle_y ()) ;
    let p = zigzag in
    pp_program (Pervasives.stdout) p ;
    interpret p 0. ;
    print_newline () ;
    Unix.sleep 5 ;
    close_graph ()

*)

let _ = Random.self_init ()

(*let print_position outx lexbuf =*)
  (*let pos = lexbuf.lex_curr_p in*)
  (*fprintf outx "%s:%d:%d" pos.pos_fname*)
    (*pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)*)

let parse_with_error lexbuf =
  Parser.program Lexer.read lexbuf
  (*| SyntaxError msg ->*)
    (*fprintf stderr "%a: %s\n" print_position lexbuf msg;*)
    (*None*)
  (*| Parser.Error ->*)
    (*fprintf stderr "%a: syntax error\n" print_position lexbuf;*)
    (*exit (-1)*)

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
    let string_from_file = file_to_string (Sys.argv.(1)) in
    match read_program string_from_file with
    | Some (n,program) ->
        pp_program Pervasives.stdout program ;
        print_newline ();
        print_int (costProgram program) ;
        print_newline ();
        moveto (middle_x ()) (middle_y ()) ;
        interpret program 0. ;
        Unix.sleep 5
| None -> failwith("Empty or malformed program")
