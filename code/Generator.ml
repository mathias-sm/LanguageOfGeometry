open Interpreter

exception InternalGenerationError of string

let dummy_var = UnitTime
let dummy_program = Turn(None)

let valuesCostVar v = (1. /. (float_of_int (Interpreter.valuesCostVar v)))
let valuesCostProgram p = match p with
    | Repeat(_,_) -> 3. *. (1. /. (float_of_int (Interpreter.valuesCostProgram p)))
    | Integrate(_,_,_) -> 3. *. (1. /. (float_of_int (Interpreter.valuesCostProgram p)))
    | Turn(_) -> 3. *. (1. /. (float_of_int (Interpreter.valuesCostProgram p)))
    | Concat(_,_) -> 2. *. (1. /. (float_of_int (Interpreter.valuesCostProgram p)))
    | _ -> (1. /. (float_of_int (Interpreter.valuesCostProgram p)))

let total_var_op   = 0.
    (*+ (valuesCostVar (Name ""))*)
    +. (valuesCostVar (Double UnitTime))
    +. (valuesCostVar (Half UnitTime))
    +. (valuesCostVar (Next UnitTime))
    +. (valuesCostVar (Prev UnitTime))
    +. (valuesCostVar (Oppos UnitTime))
    +. (valuesCostVar (Divide (UnitTime,UnitTime)))

let cumsum_op_htbl = Hashtbl.create 101

let cumsum_op var =
    let rec helper var = match var with
    | Double v -> (valuesCostVar (Double v))
    | Half v -> helper (Double v) +. (valuesCostVar (Half v))
    | Next v -> helper (Half v) +. (valuesCostVar (Next v))
    | Prev v -> helper (Next v) +. (valuesCostVar (Prev v))
    | Oppos v -> helper (Prev v) +. (valuesCostVar (Oppos v))
    | Divide(v1,v2) -> helper (Oppos v1) +. (valuesCostVar (Divide(v1,v2)))
    | _ -> raise (InternalGenerationError("in cumsum_op"))
    in if Hashtbl.mem cumsum_op_htbl var
    then Hashtbl.find cumsum_op_htbl var
    else
        let value = helper var in
        Hashtbl.add cumsum_op_htbl var value ;
        value


let total_var_unit = 0.
    +. (valuesCostVar UnitTime)
    +. (valuesCostVar UnitLoop)
    +. (valuesCostVar UnitAccel)
    +. (valuesCostVar UnitAngle)
    (*+. (valuesCostVar UnitSpeed)*)
    (*+. (valuesCostVar UnitAngularSpeed)*)
    (*+. (valuesCostVar UnitAngularAccel)*)
    +. (valuesCostVar Zero)

let cumsum_unit_htbl = Hashtbl.create 101

let cumsum_unit var =
    let rec helper var = match var with
    | UnitTime -> valuesCostVar UnitTime
    | UnitLoop -> helper UnitTime +. (valuesCostVar UnitTime)
    | UnitAccel -> helper UnitLoop +. (valuesCostVar UnitTime)
    | UnitAngle -> helper UnitAccel +. (valuesCostVar UnitTime)
    (*| UnitSpeed -> helper UnitAngle + (valuesCostVar UnitTime)*)
    (*| UnitAngularSpeed -> helper UnitSpeed + (valuesCostVar UnitTime)*)
    (*| UnitAngularAccel -> helper UnitAngularSpeed + (valuesCostVar UnitTime)*)
    | Zero -> helper UnitAngle +. (valuesCostVar UnitTime)
    | _ -> raise (InternalGenerationError("in cumsum_unit"))
    in if Hashtbl.mem cumsum_unit_htbl var
    then Hashtbl.find cumsum_unit_htbl var
    else
        let value = helper var in
        Hashtbl.add cumsum_unit_htbl var value ;
        value

let total_program = 0.
    +. (valuesCostProgram (Turn(None)))
    +. (valuesCostProgram (SavePos("")))
    +. (valuesCostProgram (SaveStroke("")))
    +. (valuesCostProgram (LoadPos("")))
    +. (valuesCostProgram (LoadStroke("")))
    +. (valuesCostProgram (Concat(dummy_program,dummy_program)))
    +. (valuesCostProgram (Repeat(None,dummy_program)))
    (*+. (valuesCostProgram (Define("",UnitTime)))*)
    +. (valuesCostProgram (Integrate(None,None,(None,None,None,None))))

let cumsum_program_htbl = Hashtbl.create 101

let cumsum_program p =
    let rec helper p = match p with
    | Turn v -> valuesCostProgram (Turn(v))
    | SavePos v -> (helper (Turn(None))) +. (valuesCostProgram (SavePos(v)))
    | SaveStroke v ->
        (helper (SavePos(v))) +. (valuesCostProgram (SaveStroke(v)))
    | LoadPos v ->
        (helper (SaveStroke(v))) +. (valuesCostProgram (LoadPos(v)))
    | LoadStroke v ->
        (helper (LoadPos(v))) +. (valuesCostProgram (LoadStroke(v)))
    | Concat (p1,p2) ->
        (helper (LoadStroke(""))) +. (valuesCostProgram (Concat(p1,p2)))
    | Repeat (r,p) ->
        (helper (Concat(dummy_program,dummy_program)))
        +. (valuesCostProgram (Repeat(r,p)))
    (*| Define (s,v) ->*)
        (*(helper (Repeat(None,dummy_program)))*)
        (*+ (valuesCostProgram (Define(s,v)))*)
    | Integrate (v1,v2,v3) ->
        (helper (Repeat(None,dummy_program)))
        +. (valuesCostProgram (Integrate(v1,v2,v3)))
    | _ -> raise (InternalGenerationError("in sumsum_program"))
    in if Hashtbl.mem cumsum_program_htbl p
    then Hashtbl.find cumsum_program_htbl p
    else
        let value = helper p in
        Hashtbl.add cumsum_program_htbl p value ;
        value

let rec get_random_var : unit -> var = fun () ->
    if Random.bool () then
        match Random.float total_var_unit with
        | n when n < cumsum_unit UnitTime -> UnitTime
        | n when n < cumsum_unit UnitLoop -> UnitLoop
        | n when n < cumsum_unit UnitAccel -> UnitAccel
        | n when n < cumsum_unit UnitAngle -> UnitAngle
        (*| n when n < cumsum_unit UnitSpeed -> UnitSpeed*)
        (*| n when n < cumsum_unit UnitAngularSpeed -> UnitAngularSpeed*)
        (*| n when n < cumsum_unit UnitAngularAccel -> UnitAngularAccel*)
        | n when n < cumsum_unit Zero -> Zero
        | _ -> raise (InternalGenerationError("in total_var_unit"))
    else
        match Random.float total_var_op with
        | n when n < cumsum_op (Double(dummy_var)) ->
            Double (get_random_var ())
        | n when n < cumsum_op (Half(dummy_var)) ->
            Half (get_random_var ())
        | n when n < cumsum_op (Next(dummy_var)) ->
            Next (get_random_var ())
        | n when n < cumsum_op (Prev(dummy_var)) ->
            Prev (get_random_var ())
        | n when n < cumsum_op (Oppos(dummy_var)) ->
            Oppos (get_random_var ())
        | n when n < cumsum_op (Divide(dummy_var,dummy_var)) ->
            Divide (get_random_var (), get_random_var ())
        | _ -> raise (InternalGenerationError("in total_var_op"))


let rec generate_random : unit -> program = fun () ->
    match Random.float total_program with
    | n when n < cumsum_program (Turn(None)) ->
        let b = Random.bool () in
        let var = if b then Some(get_random_var ()) else None in
        Turn(var)
    | n when n < cumsum_program (SavePos("")) ->
        SavePos("pos")
    | n when n < cumsum_program (SaveStroke("")) ->
        SavePos("stroke")
    | n when n < cumsum_program (LoadPos("")) ->
        LoadPos("pos")
    | n when n < cumsum_program (LoadStroke("")) ->
        LoadStroke("stroke")
    | n when n < cumsum_program (Concat(dummy_program,dummy_program)) ->
        Concat(generate_random (),generate_random ())
    | n when n < cumsum_program (Repeat(None,dummy_program)) ->
        let b = Random.bool () in
        let var = if b then Some(get_random_var ()) else None in
        Repeat(var ,generate_random ())
    | n when n < cumsum_program (Integrate(None,None,(None,None,None,None))) ->
        let varArray = Array.make 5 None in
        for i = 0 to 4 do
            if Random.int 8 = 0 then
            varArray.(i) <- Some(get_random_var ())
        done ;
        Integrate(varArray.(0),
                 (if Random.bool () then None else Some(Random.bool ())),
                 (varArray.(1),
                  varArray.(2),
                  varArray.(3),
                  varArray.(4)))
    | _ -> raise (InternalGenerationError("in generate_random"))
