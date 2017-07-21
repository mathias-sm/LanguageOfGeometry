open Hashtbl
open Random
open Printf
open Plotter
open Utils

type var =    Name of string
            | UnitAngle | UnitTime | UnitLoop
            | UnitSpeed | UnitAccel | UnitAngularSpeed | UnitAngularAccel
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
             | SavePos of string
             | SaveStroke of string
             | LoadPos of string
             | LoadStroke of string
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

type stack = internal list

let rec my_print_var v = match v with
    | Name s -> s
    | Zero -> "0"
    | UnitAngle -> "unit_angle"
    | UnitTime -> "unit_time"
    | UnitLoop -> "unit_loop"
    | UnitSpeed -> "unit_speed"
    | UnitAccel -> "unit_accel"
    | UnitAngularSpeed -> "unit_angular_speed"
    | UnitAngularAccel -> "unit_angular_accel"
    | Double v' -> "Double(" ^ (my_print_var v') ^ ")"
    | Half v' -> "Half(" ^ (my_print_var v') ^ ")"
    | Next v' -> "Next(" ^ (my_print_var v') ^ ")"
    | Prev v' -> "Prev(" ^ (my_print_var v') ^ ")"
    | Oppos v' -> "Oppos(" ^ (my_print_var v') ^")"
    | Divide (v1,v2) ->
        "Divide(" ^ (my_print_var v1) ^ ","^(my_print_var v2)^")"

let (++) pr1 pr2 = Concat(pr1, pr2)

let replace_pos curr future =
    curr.x <- future.x ;
    curr.y <- future.y

let replace_stroke curr future =
    curr.face <- future.face ;
    curr.speed <- future.speed ;
    curr.accel <- future.accel ;
    curr.angularSpeed <- future.angularSpeed ;
    curr.angularAccel <- future.angularAccel

let replace curr future =
    replace_pos curr future ; replace_stroke curr future

let (<<-) curr future = replace curr future

let pp_program channel program =
    let rec pp_helper program tabs = match program with
        | Concat (p1,p2) ->
                pp_helper p1 tabs ; Printf.fprintf channel " ;\n" ; pp_helper p2 tabs
        | SavePos name -> Printf.fprintf channel "%sSavePos(\"%s\")" tabs name
        | SaveStroke name -> Printf.fprintf channel "%sSaveStroke(\"%s\")" tabs name
        | LoadPos name -> Printf.fprintf channel "%sLoadPos(\"%s\")" tabs name
        | LoadStroke name -> Printf.fprintf channel "%sLoadStroke(\"%s\")" tabs name
        | Turn f -> Printf.fprintf channel "%sTurn%s" tabs
            (match f with
            | None -> ""
            | Some(f) -> sprintf "(angle=%s)" (my_print_var f))
        | Repeat (n,pr) ->
            Printf.fprintf channel "%sRepeat%s {\n" tabs
                (match n with
                | None -> ""
                | Some(m) when m = UnitLoop -> ""
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
    let unit_cost = 1 in
    fun v -> match v with
    | UnitTime -> unit_cost | UnitLoop -> unit_cost | UnitAccel -> unit_cost
    | UnitAngle -> unit_cost | UnitSpeed -> unit_cost
    | UnitAngularAccel -> unit_cost | UnitAngularSpeed -> unit_cost
    | Zero -> unit_cost
    | Name _ -> 1
    | Double v' ->  1
    | Half v' ->  1
    | Next v' ->  1
    | Prev v' ->  1
    | Oppos v' ->  1
    | Divide(v1,v2) -> 1

let costVar : var option -> int =
    let rec helper v = match v with
        | UnitTime -> valuesCostVar UnitTime
        | UnitLoop -> valuesCostVar UnitLoop
        | UnitAccel -> valuesCostVar UnitAccel
        | UnitAngle -> valuesCostVar UnitAngle
        | UnitSpeed -> valuesCostVar UnitSpeed
        | UnitAngularSpeed -> valuesCostVar UnitAngularSpeed
        | UnitAngularAccel -> valuesCostVar UnitAngularAccel
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
    | SavePos _ -> 1
    | SaveStroke _ -> 1
    | LoadPos _ -> 1
    | LoadStroke _ -> 1
    | Concat (_,_) -> 1
    | Repeat (_,_) -> 1
    | Define (_,_) -> 1
    | Integrate(_,_,_) -> 1

let rec costProgram : program -> int =
    fun p -> match p with
    | Turn v -> (valuesCostProgram (Turn v)) + (costVar v)
    | SavePos s -> (valuesCostProgram (SavePos s))
    | SaveStroke s -> (valuesCostProgram (SaveStroke s))
    | LoadPos s -> (valuesCostProgram (LoadPos s))
    | LoadStroke s -> (valuesCostProgram (LoadStroke s))
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
let rec evaluateVarHelper v htbl_var = match v with
    | UnitTime -> (unitTime,fun () -> unitTime)
    | UnitAngle -> (unitTurn,fun () -> unitTurn)
    | UnitLoop -> (float_of_int unitLoop, fun () -> (float_of_int unitLoop))
    | Zero -> (0., fun () -> 0.)
    | UnitSpeed -> (baseSpeed, fun () -> baseSpeed)
    | UnitAccel -> (baseAccel, fun () -> baseAccel)
    | UnitAngularSpeed -> (baseAngularSpeed, fun () -> baseAngularSpeed)
    | UnitAngularAccel -> (baseAngularAccel, fun () -> baseAngularAccel)
    | Double v' ->
        let v,u = (evaluateVarHelper v' htbl_var) in (2.*.v,u)
    | Half v' ->
        let v,u = (evaluateVarHelper v' htbl_var) in (v/.2.,u)
    | Next v' ->
        let v,u = (evaluateVarHelper v' htbl_var) in (v+.(u ()),u)
    | Prev v' ->
        let v,u = (evaluateVarHelper v' htbl_var) in (v-.(u ()),u)
    | Oppos v' ->
        let v,u = (evaluateVarHelper v' htbl_var) in ((-1.)*.v,u)
    | Divide (v1,v2) ->
        let (v1,u1) = evaluateVarHelper v1 htbl_var in
        let (v2,u2) = evaluateVarHelper v2 htbl_var in
        let r = v1 /. v2 in
        if (u1 ()) = (u2 ()) then (r,u1)
        else (r,
            fun () -> (raise (MalformedProgram("Next/Prev over Divide is
            ill-defined"))))
    | Name s ->
        if Hashtbl.mem htbl_var s then
            let value = Hashtbl.find htbl_var s in
            Hashtbl.remove htbl_var s ;
            let v,u = evaluateVarHelper value htbl_var in
            Hashtbl.add htbl_var s value ;
            (v,u)
        else raise (MalformedProgram(s ^ "unknown in evaluateVar"))
in let v,_ = evaluateVarHelper v htbl_var in v

let interpret : canvas -> program -> canvas =
    fun canvas program  ->
    let has_started = ref false in
    let rec inter canvas program htbl_pos htbl_stroke htbl_var curr_state =
        match program with
        | SavePos name ->
            let save_state =
                {curr_state with x = curr_state.x} in
            Hashtbl.add htbl_pos name save_state ;
            canvas
        | SaveStroke name ->
            let save_state =
                {curr_state with x = curr_state.x} in
            Hashtbl.add htbl_stroke name save_state ;
            canvas
        | LoadPos name ->
            (try
                replace_pos curr_state (Hashtbl.find htbl_pos name) ;
                moveto canvas curr_state.x curr_state.y
            with _ -> raise (MalformedProgram
                                (Printf.sprintf "%s non existent" name)
                            ))
        | LoadStroke name ->
            (try
                replace_stroke curr_state (Hashtbl.find htbl_stroke name) ;
                canvas
            with _ -> raise (MalformedProgram
                                (Printf.sprintf "%s non existent" name)
                            ))
        | Turn f ->
                let angle : float = match f with None -> unitTurn | Some(f') ->
                    evaluateVar f' htbl_var in
                if !has_started
                    then curr_state.face <- curr_state.face +. angle ;
                canvas
        | Concat (p1,p2) ->
            let new_canvas =
                inter canvas p1 htbl_pos htbl_stroke htbl_var curr_state
            in inter new_canvas p2 htbl_pos htbl_stroke htbl_var curr_state
        | Repeat (n, pr) ->
            let n' = int_of_float (match n with
                | None -> float_of_int unitLoop
                | Some v -> evaluateVar v htbl_var) in
            (*for i = 1 to (int_of_float n') do*)
                (*inter pr htbl_pos htbl_stroke htbl_var curr_state*)
            (*done*)
            let rec helper n canvas = match n with
            | 0 -> canvas
            | n ->
                let new_canvas =
                    inter canvas pr htbl_pos htbl_stroke htbl_var curr_state
                in helper (n-1) new_canvas
            in if n' <= 0 then canvas else helper n' canvas
        | Integrate (f, pen, (speed,accel,angularSpeed,angularAccel)) ->
            let f = match f with None -> unitTime
                    | Some v -> evaluateVar v htbl_var in
            let speed =
                (match speed with None -> curr_state.speed
                    | Some v -> evaluateVar v htbl_var) and
            accel =
                (match accel with None -> defaultAccel
                    | Some v -> evaluateVar v htbl_var) and
            angularSpeed =
                (match angularSpeed with None -> defaultAngularSpeed
                    | Some v -> evaluateVar v htbl_var) and
            angularAccel =
                (match angularAccel with None -> defaultAngularAccel
                    | Some v -> evaluateVar v htbl_var) in
            curr_state.speed <- speed ;
            curr_state.accel <- accel ;
            curr_state.angularSpeed <- angularSpeed ;
            curr_state.angularAccel <- angularAccel ;
            let pen = match pen with | None -> true | Some b -> b in
            if pen then has_started := true ;
            let r_canvas = ref canvas in
            if !has_started then begin
                for i = 0 to (int_of_float (50. *. pi *. f)) do
                    let futur_x =
                        curr_state.x
                     +. (curr_state.speed /. 10.) *. cos(curr_state.face)
                    and futur_y =
                        curr_state.y
                     +. (curr_state.speed /. 10.) *. sin(curr_state.face) in
                    r_canvas :=
                        if pen then lineto !r_canvas futur_x futur_y
                        else moveto !r_canvas futur_x futur_y ;
                    curr_state.x <- futur_x ;
                    curr_state.y <- futur_y ;
                    curr_state.face <-
                        curr_state.face +. (curr_state.angularSpeed /. (100.*.pi)) ;
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
    inter canvas program  (Hashtbl.create 101) (Hashtbl.create 101) (Hashtbl.create 101) initial_state
