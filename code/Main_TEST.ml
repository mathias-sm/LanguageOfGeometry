open Plotter
open Interpreter
open Printf
open Generator
open Unix

let _ = Random.self_init ()

let line : program =
    Integrate(None,None,(None,None,None,None))

let square : program =
    Repeat(None,Repeat(None,Concat(Integrate(None,None,(None,None,None,None)),Turn(None))))

let circle : program =
    Repeat(None,Integrate(None,None,(None,None,Some(Unit),None)))

let sideBySide : program =
    Concat(square,Concat(Integrate(Some(Double(Unit)),Some false,(None,None,None,None)),circle))

 let zigzag : program =
    Concat(
        Define("turn", Unit),
            Repeat(Some(Indefinite),
            Concat(
                Integrate(Some(Half(Half(Unit))),None,(None,None,None,None)),
                Concat(
                    Turn(Some(Name("turn"))),
                    Define("turn", Opposite(Name("turn")))
                )
                )
        ))

(*let buggy : program =*)
    (*Repeat(Some(Oppos(UnitTime)),Turn(None))*)

(*let buggy2 : program =*)
    (*Repeat(None,Integrate(None,Some true,(None,None,None,None)))*)

(*let buggy3 : program =*)
    (*Integrate(None,None,(Some(UnitTime),None,None,None))*)

(*let buggy4 : program =*)
    (*Integrate(None,None,(Some(Oppos(UnitLoop)),None,None,None))*)

let oneMore = Concat(sideBySide, sideBySide)

let () =
    let v = Generator.get_random_var [] in
    print_endline (Interpreter.my_print_var v)
    (*let c = new_canvas () in*)
    (*let p = zigzag in*)
    (*let s = pp_program p in*)
    (*Printf.printf "%s\n" s ;*)
    (*print_endline "Will interpret!" ;*)
    (*let c = interpret c p in*)
    (*print_endline "Did interpret!" ;*)
    (*print_newline () ;*)
    (*ignore (canvas_to_hashable c) ;*)
    (*Renderer.output_canvas_png c "./toto.png"*)
