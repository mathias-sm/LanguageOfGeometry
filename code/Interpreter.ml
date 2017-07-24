open Hashtbl
open Random
open Printf
open Plotter
open Utils

type var =    Name of string
            | Unit
            | Zero
            | Double of var | Half of var
            | Next of var | Prev of var
            | Oppos of var
            | Divide of var * var

type innerValues = var option
                 * var option
                 * var option
                 * var option

type program = Concat of program * program
             | Embed of program
             | Turn of var option
             | Repeat of var option * program
             | Integrate of var option * bool option * innerValues
             | Define of string * var

type internal = { mutable x             : float
                ; mutable y             : float
                ; mutable face          : float
                ; mutable speed         : float
                ; mutable accel         : float
                ; mutable angularSpeed  : float
                ; mutable angularAccel  : float }

exception MalformedProgram of string

let rec my_print_var v = match v with
    | Name s -> s
    | Zero -> "0"
    | Unit -> "unit"
    | Double v' -> "Double(" ^ (my_print_var v') ^ ")"
    | Half v' -> "Half(" ^ (my_print_var v') ^ ")"
    | Next v' -> "Next(" ^ (my_print_var v') ^ ")"
    | Prev v' -> "Prev(" ^ (my_print_var v') ^ ")"
    | Oppos v' -> "Oppos(" ^ (my_print_var v') ^")"
    | Divide (v1,v2) ->
        "Divide(" ^ (my_print_var v1) ^ ","^(my_print_var v2)^")"

let (++) pr1 pr2 = Concat(pr1, pr2)

let replace_stroke curr future =
    curr.face <- future.face ;
    curr.speed <- future.speed ;
    curr.accel <- future.accel ;
    curr.angularSpeed <- future.angularSpeed ;
    curr.angularAccel <- future.angularAccel

let empty_state =
        { x = -1.
        ; y = -1.
        ; face = 0.
        ; speed = 1.
        ; accel = 0.
        ; angularSpeed = 0.
        ; angularAccel = 0. }


let replace curr future =
    curr.x <- future.x ;
    curr.y <- future.y ;
    curr.face <- future.face ;
    curr.speed <- future.speed ;
    curr.accel <- future.accel ;
    curr.angularSpeed <- future.angularSpeed ;
    curr.angularAccel <- future.angularAccel

let (<<-) curr future = replace curr future

let pp_program channel program =
    let rec pp_helper program tabs = match program with
        | Concat (p1,p2) ->
                pp_helper p1 tabs ; Printf.fprintf channel " ;\n" ; pp_helper p2 tabs
        | Turn f -> Printf.fprintf channel "%sTurn%s" tabs
            (match f with
            | None -> ""
            | Some(f) -> sprintf "(angle=%s)" (my_print_var f))
        | Embed pr ->
            Printf.fprintf channel "%sEmbed {\n" tabs ;
            pp_helper pr (Printf.sprintf "%s  " tabs) ;
            Printf.fprintf channel "\n%s}" tabs
        | Repeat (n,pr) ->
            Printf.fprintf channel "%sRepeat%s {\n" tabs
                (match n with
                | None -> ""
                | Some(m) when m = Unit -> ""
                | Some(m) -> "("^my_print_var m^")");
            pp_helper pr (Printf.sprintf "%s  " tabs) ;
            Printf.fprintf channel "\n%s}" tabs
        | Integrate (f,pen,(speed,accel,angularSpeed,angularAccel)) ->
            Printf.fprintf channel "%sIntegrate%s"
            tabs
            (if f = None && pen = None && speed = None && accel = None &&
                angularSpeed = None && angularAccel = None then ""
            else (let s = ref "(" in begin
                (match f with None->()|Some(f)->s:=!s^"t="^my_print_var f^",");
                (match pen with None->()|Some(p)->s:=!s^"pen="^(my_print_bool p)^",");
                (match speed with None->()|Some(f)->s:=!s^"speed="^my_print_var f^",");
                (match accel with None->()|Some(f)->s:=!s^"accel="^my_print_var f^",");
                (match angularSpeed with None->()|Some(f)->s:=!s^"angularSpeed="^my_print_var f^",");
                (match angularAccel with None->()|Some(f)->s:=!s^"angularAccel="^my_print_var f^",");
            end ; ((String.sub !s 0 ((String.length !s) - 1))^")")))
        | Define (name,v) ->
            Printf.fprintf channel "%s%s = %s" tabs name (my_print_var v)
    in
    pp_helper program "" ; print_newline ()

let valuesCostVar : var -> int =
    fun v -> match v with
    | Unit -> 1
    | Zero -> 1
    | Name _ -> 1
    | Double v' ->  1
    | Half v' ->  1
    | Next v' ->  1
    | Prev v' ->  1
    | Oppos v' ->  1
    | Divide(v1,v2) -> 1

let costVar : var option -> int =
    let rec helper v = match v with
        | Unit -> valuesCostVar Unit
        | Zero -> valuesCostVar Zero
        | Name s -> valuesCostVar (Name s)
        | Double v' ->  (valuesCostVar (Double v')) + helper v'
        | Half v' ->  (valuesCostVar (Half v')) + helper v'
        | Prev v' ->  (valuesCostVar (Prev v')) + helper v'
        | Next v' ->  (valuesCostVar (Next v')) + helper v'
        | Oppos v' ->  (valuesCostVar (Oppos v')) + helper v'
        | Divide(v1,v2) -> (valuesCostVar (Divide(v1,v2))) + helper v1 + helper v2
    in fun vo -> match vo with
    | None -> 0
    | Some v -> helper v

let valuesCostProgram : program -> int =
    fun p -> match p with
    | Turn _ -> 1
    | Embed _ -> 1
    | Concat (_,_) -> 1
    | Repeat (_,_) -> 1
    | Define (_,_) -> 1
    | Integrate(_,_,_) -> 1

let rec costProgram : program -> int =
    fun p -> match p with
    | Turn v -> (valuesCostProgram (Turn v)) + (costVar v)
    | Embed (p) -> (valuesCostProgram (Embed(p))) + costProgram p
    | Concat (p1,p2) -> (valuesCostProgram (Concat (p1,p2)))
                        + costProgram p1 + costProgram p2
    | Repeat (v,p') -> (valuesCostProgram (Repeat(v,p')))
                       + (costVar v) + (costProgram p')
    | Define (s,v) -> (valuesCostProgram (Define (s,v)))
                      + costVar (Some v)
    | Integrate(v1,v2,(v3,v4,v5,v6)) ->
            (valuesCostProgram (Integrate(v1,v2,(v3,v4,v5,v6))))
          + costVar v1
          + (match v2 with None -> 0 | Some _ -> 1)
          + costVar v3
          + costVar v4
          + costVar v5
          + costVar v6

let evaluateVar v htbl_var =
    let rec evaluateVar_helper v htbl_var = match v with
    | Unit -> 1.
    | Zero -> 0.
    | Double v' -> 2.*.(evaluateVar_helper v' htbl_var)
    | Half v' -> (evaluateVar_helper v' htbl_var) /. 2.
    | Prev v' -> (evaluateVar_helper v' htbl_var) -. 1.
    | Next v' -> (evaluateVar_helper v' htbl_var) +. 1.
    | Oppos v' -> (-1.)*.(evaluateVar_helper v' htbl_var)
    | Divide (v1,v2) -> (evaluateVar_helper v1 htbl_var) /.
    (evaluateVar_helper v2 htbl_var)
    | Name s ->
        if Hashtbl.mem htbl_var s then
            let value = Hashtbl.find htbl_var s in
            Hashtbl.remove htbl_var s ;
            let v = evaluateVar_helper value htbl_var in
            Hashtbl.add htbl_var s value ;
            v
        else raise (MalformedProgram(s ^ "unknown in evaluateVar"))
    in match evaluateVar_helper v htbl_var with
    | n when n = nan -> raise (MalformedProgram("Some var was NaN"))
    | f -> f

let interpret : canvas -> program -> canvas =
    fun canvas program  ->
    let has_started = ref false in
    let rec inter canvas program htbl_var curr_state =
        match program with
        | Embed p ->
            let save_state =
                {curr_state with x = curr_state.x} in
            replace_stroke curr_state empty_state ;
            let htbl_var' = Hashtbl.copy htbl_var in
            let canvas =
                inter canvas p htbl_var' curr_state in
            replace curr_state save_state ;
            canvas
        | Turn f ->
                let angle : float = match f with None -> 1. | Some(f') ->
                    evaluateVar f' htbl_var in
                if !has_started
                    then curr_state.face <- curr_state.face +. angle *. pis2 ;
                canvas
        | Concat (p1,p2) ->
            let new_canvas =
                inter canvas p1 htbl_var curr_state
            in inter new_canvas p2 htbl_var curr_state
        | Repeat (n, pr) ->
            has_started := true;
            let n' = int_of_float (match n with
                | None -> 2.
                | Some v -> evaluateVar v htbl_var) in
            let rec helper n canvas = match n with
            | 0 -> canvas
            | n ->
                let new_canvas =
                    inter canvas pr htbl_var curr_state
                in helper (n-1) new_canvas
            in if n' <= 0 then canvas else helper n' canvas
        | Integrate (f, pen, (speed,accel,angularSpeed,angularAccel)) ->
            let f = match f with None -> 1.
                    | Some v -> evaluateVar v htbl_var in
            let speed =
                (match speed with None -> curr_state.speed
                    | Some v -> evaluateVar v htbl_var) and
            accel =
                (match accel with None -> curr_state.accel
                    | Some v -> evaluateVar v htbl_var) and
            angularSpeed =
                (match angularSpeed with None -> curr_state.angularSpeed
                    | Some v -> evaluateVar v htbl_var) and
            angularAccel =
                (match angularAccel with None -> curr_state.angularAccel
                    | Some v -> evaluateVar v htbl_var) in
            curr_state.speed <- speed ;
            curr_state.accel <- accel ;
            curr_state.angularSpeed <- angularSpeed ;
            curr_state.angularAccel <- angularAccel ;
            let pen = match pen with | None -> true | Some b -> b in
            if pen then has_started := true ;
            let r_canvas = ref canvas in
            if !has_started then begin
                for i = 0 to (int_of_float (1000. *. pi *. f)) do
                    let futur_x =
                        curr_state.x
                     +. (curr_state.speed /. 250.) *. cos(curr_state.face)
                    and futur_y =
                        curr_state.y
                     +. (curr_state.speed /. 250.) *. sin(curr_state.face) in
                    r_canvas :=
                        if pen then lineto !r_canvas futur_x futur_y
                        else moveto !r_canvas futur_x futur_y ;
                    curr_state.x <- futur_x ;
                    curr_state.y <- futur_y ;
                    curr_state.face <-
                        curr_state.face +. (curr_state.angularSpeed /. 500.) ;
                    curr_state.speed <-
                        curr_state.speed +. (curr_state.accel /. 2500.) ;
                    curr_state.angularSpeed <-
                        curr_state.angularSpeed +. (curr_state.angularAccel /.
                        10000000.)
                done
            end ;
            !r_canvas
        | Define (name,v) -> Hashtbl.add htbl_var name v ; canvas
    in let initial_state =
        { x = middle_x canvas
        ; y = middle_y canvas
        ; face = 0.
        ; speed = 1.
        ; accel = 0.
        ; angularSpeed = 0.
        ; angularAccel = 0. }
    in
    inter canvas program (Hashtbl.create 101) initial_state
