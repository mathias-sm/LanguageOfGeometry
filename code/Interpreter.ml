open Graphics
open Hashtbl
open Unix
open Random

type program = Concat of program * program
             | SetValues of float * float * float * float
             | Save of string
             | Load of string
             | LoadPos of string
             | LoadStroke of string
             | Turn of float
             | DiscreteRepeat of int * program option
             | Integrate of float * bool
             | Nop

type internal = { mutable x : float
                ; mutable y : float
                ; mutable face : float
                ; mutable v : float
                ; mutable v' : float
                ; mutable th : float
                ; mutable th' : float }

exception MalformedProgram of string

type stack = internal list

let pi = 4. *. atan(1.)
let pi2 = pi /. 2.
let pi4 = pi /. 4.

let (++) pr1 pr2 = Concat(pr1, pr2)

let random_normal () = sqrt(-2.*.log(Random.float 1.))*.cos(2.*.pi*.Random.float 1.)

let replace_pos curr future =
    curr.x <- future.x ;
    curr.y <- future.y

let replace_stroke curr future =
    curr.face <- future.face ;
    curr.v <- future.v ;
    curr.v' <- future.v' ;
    curr.th <- future.th ;
    curr.th' <- future.th'

let replace curr future =
    replace_pos curr future ; replace_stroke curr future

let (<<-) curr future = replace curr future

let print_float f = match f with
 | f when f = pi  -> "π"
 | f when f = pi2 -> "π/2"
 | f when f = pi4 -> "π/4"
 | f when f = (-1.) *. pi  -> "-π"
 | f when f = (-1.) *. pi2 -> "-π/2"
 | f when f = (-1.) *. pi4 -> "-π/4"
 | _ -> Printf.sprintf "%.3g" f

let print_bool b = match b with
 | true -> "on"
 | false -> "off"

let pp_program channel program =
    let rec pp_helper program tabs = match program with
        | Concat (p1,p2) ->
                pp_helper p1 tabs ; Printf.fprintf channel " ;\n" ; pp_helper p2 tabs
        | SetValues (v', th', v'', th'') ->
            Printf.fprintf channel "%sSetValues(speed=%s, angularSpeed=%s, accel=%s, angularAccel=%s)"
                tabs (print_float v') (print_float th') (print_float v'') (print_float th'')
        | Save name -> Printf.fprintf channel "%sSave(\"%s\")" tabs name
        | Load name -> Printf.fprintf channel "%sLoad(\"%s\")" tabs name
        | LoadPos name -> Printf.fprintf channel "%sLoadPos(\"%s\")" tabs name
        | LoadStroke name -> Printf.fprintf channel "%sLoadStroke(\"%s\")" tabs name
        | Turn f -> Printf.fprintf channel "%sTurn(%s)"
                        tabs (print_float f)
        | DiscreteRepeat (n,pr) ->
            Printf.fprintf channel "%sDiscreteRepeat(%d){\n" tabs n ;
            (match pr with
                | Some pr -> pp_helper pr (Printf.sprintf "%s  " tabs)
                | None -> ()) ;
            Printf.fprintf channel "\n%s}" tabs
        | Integrate (f,pen) ->
            Printf.fprintf channel "%sIntegrate(%s,pen=%s)"
            tabs (print_float f) (print_bool pen);
        | Nop ->
            Printf.fprintf channel "%sNop" tabs;
    in
    pp_helper program ""

let interpret program noise =
    let rec inter program htbl curr_state =
        match program with
        | Save name ->
            let save_state =
                {curr_state with x = curr_state.x} in
            Hashtbl.add htbl name save_state
        | Load name ->
            (try
                replace curr_state (Hashtbl.find htbl name) ;
                moveto
                    (int_of_float curr_state.x)
                    (int_of_float curr_state.y)
            with _ -> raise (MalformedProgram
                                (Printf.sprintf "%s non existent" name)
                            ))
        | LoadPos name ->
            (try
                replace_pos curr_state (Hashtbl.find htbl name) ;
                moveto
                    (int_of_float curr_state.x)
                    (int_of_float curr_state.y)
            with _ -> raise (MalformedProgram
                                (Printf.sprintf "%s non existent" name)
                            ))
        | LoadStroke name ->
            (try replace_stroke curr_state (Hashtbl.find htbl name)
            with _ -> raise (MalformedProgram
                                (Printf.sprintf "%s non existent" name)
                            ))
        | Turn f ->
            curr_state.face <- curr_state.face +. f
                               +. random_normal () *. noise *. 100.;
        | SetValues (v,th,v',th') ->
            curr_state.v <- v ;
            curr_state.th <- th ;
            curr_state.v' <- v' ;
            curr_state.th' <- th'
        | Concat (p1,p2) ->
            inter p1 htbl curr_state ;
            inter p2 htbl curr_state
        | DiscreteRepeat (n, pr) ->
            (match n with
                | 0 -> ()
                | n -> (match pr with
                    | Some pr ->
                        inter pr htbl curr_state ;
                        inter (DiscreteRepeat(n-1, (Some pr))) htbl curr_state
                    | None -> ()))
        | Integrate (f, pen) ->
            for i = 0 to (int_of_float f) do
                let futur_x =
                    curr_state.x
                 +. curr_state.v *. cos(curr_state.face)
                and futur_y =
                    curr_state.y
                 +. curr_state.v *. sin(curr_state.face) in
                if pen then
                    lineto (int_of_float futur_x)
                           (int_of_float futur_y)
                else
                    moveto (int_of_float futur_x)
                           (int_of_float futur_y) ;
                curr_state.x <- futur_x ;
                curr_state.y <- futur_y ;
                curr_state.face <-
                    curr_state.face +. curr_state.th
                    +. random_normal () *. noise ;
                curr_state.v <-
                    curr_state.v +. curr_state.v'
                    +. random_normal () *. noise /. pi;
                curr_state.th <-
                    curr_state.th +. curr_state.th'
            done
        | Nop -> ()
    in let initial_state =
        { x = ((float_of_int (size_x ())) /. 2.)
        ; y = ((float_of_int (size_y ())) /. 2.)
        ; face = 0.
        ; v = 1.
        ; v' = 0.
        ; th = 0.
        ; th' = 0. }
    in let l = inter program (Hashtbl.create 101) initial_state in
    match l with _ -> ()
