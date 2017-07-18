open Graphics
open Plotter
open Interpreter
open Printf
open Generator
open Images
open Unix

let _ = Random.self_init ()

let memory : (color array array, (int*int)) Hashtbl.t = Hashtbl.create 10007

let () =
    open_graph "" ;
    let counter = ref 1 in
    let sup = 1000000 in
    for i = 1 to sup do
        set_line_width 4 ;
        auto_synchronize false ;
        display_mode false ;
        remember_mode true ;
        let p = generate_random () in
        clear_graph () ;
        moveto (middle_x ()) (middle_y ()) ;
        try begin
            interpret p 0. ;
            let cost = costProgram p in
            let image = get_image 0 0 (size_x ()) (size_y ()) in
            let result = dump_image image in
            if Hashtbl.mem memory result then begin
                let (prev,id_first) = Hashtbl.find memory result in
                if prev > cost then begin
                    Hashtbl.replace memory result (cost,id_first) ;
                    Printf.printf "Found a better %d !" id_first ;
                    let oc = open_out (Printf.sprintf "/tmp/enum/%d.LoG"
                    id_first) in
                    let oc_w = open_out (Printf.sprintf "/tmp/enum/%d.cost"
                    id_first) in
                    Png.save
                        (Printf.sprintf "/tmp/enum/%d.png" id_first) []
                        (Rgb24 (Graphic_image.get_image 0 0 (size_x ()) (size_y
                        ()))) ;
                    pp_program oc p ;
                    Printf.fprintf oc_w "%d\n" cost ;
                    close_out oc ;
                    close_out oc_w
                    end
                else ()
                end
            else begin
                Hashtbl.add memory result (cost,!counter) ;
                Printf.printf "%d is new !" !counter ;
                let oc = open_out (Printf.sprintf "/tmp/enum/%d.LoG" !counter) in
                let oc_w = open_out (Printf.sprintf "/tmp/enum/%d.cost"
                !counter) in
                Png.save
                    (Printf.sprintf "/tmp/enum/%d.png" !counter) []
                    (Rgb24 (Graphic_image.get_image 0 0 (size_x ()) (size_y
                    ()))) ;
                pp_program oc p ;
                Printf.fprintf oc_w "%d\n" cost ;
                close_out oc ;
                close_out oc_w ;
                counter := !counter + 1 ;
            end
        end
        with MalformedProgram(s) -> ()
    done ;
    close_graph ()

(*
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



(*let print_position outx lexbuf =*)
  (*let pos = lexbuf.lex_curr_p in*)
  (*fprintf outx "%s:%d:%d" pos.pos_fname*)
    (*pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)*)

(*let parse_with_error lexbuf =*)
  (*Parser.program Lexer.read lexbuf*)
  (*| SyntaxError msg ->*)
    (*fprintf stderr "%a: %s\n" print_position lexbuf msg;*)
    (*None*)
  (*| Parser.Error ->*)
    (*fprintf stderr "%a: syntax error\n" print_position lexbuf;*)
    (*exit (-1)*)

(*let read_program program_string =*)
  (*let lexbuf = Lexing.from_string program_string in*)
  (*let program = parse_with_error lexbuf in*)
  (*program*)

(*let file_to_string filename =*)
    (*let ic = open_in filename in*)
    (*let n = in_channel_length ic in*)
    (*let s = Bytes.create n in*)
    (*really_input ic s 0 n;*)
    (*close_in ic;*)
    (*s*)

(*let () =*)
    (*for i = 0 to 5 do*)
        (*let p = Generator.generate_random () in*)
        (*pp_program Pervasives.stdout p ;*)
        (*print_newline ()*)
    (*done ;*)
    (*open_graph "" ;*)
    (*let string_from_file = file_to_string (Sys.argv.(1)) in*)
    (*match read_program string_from_file with*)
    (*| Some (n,program) ->*)
        (*pp_program Pervasives.stdout program ;*)
        (*print_newline ();*)
        (*print_int (costProgram program) ;*)
        (*print_newline ();*)
        (*moveto (middle_x ()) (middle_y ()) ;*)
        (*interpret program 0. ;*)
        (*Unix.sleep 5*)
(*| None -> failwith("Empty or malformed program")*)
*)
