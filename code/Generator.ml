open Interpreter

(*type program = Concat of program * program*)
             (*| SetValues of float * float * float * float*)
             (*| Save of string*)
             (*| Load of string*)
             (*| Turn of float*)
             (*| DiscreteRepeat of int * program option*)
             (*| Integrate of float*)
             (*| Nop*)

type cursor =
    | CC of int*int
    | CR of int
    | CSV | CL | CS | CT | CI (*| CN *)

let rec at : program list -> int -> program option =
    fun l n -> match l with
    | e :: r -> if n = 0 then Some e else at r (n-1)
    | [] -> None

let generate_helper : unit -> program option =
    let past : program list ref = ref [] in
    let next : program list ref = ref [] in
    let cursor : cursor ref = ref CI in
    fun () ->
        let return : program option =
        (match !cursor with
        (*| CN -> cursor := CI ; Some(Nop)*)
        | CI -> cursor := CT ; Some(Integrate(100.))
        | CT -> cursor := CS ; Some(Turn(pi /. 2.))
        | CS -> cursor := CL ; Some(Save("a"))
        | CL -> cursor := CSV ; Some(Load("a"))
        | CSV -> cursor := CR(0) ; Some(SetValues(1.,0.,0.,0.))
        | CR(n) ->
            (match at !past n with
            | Some p -> cursor := CR(n+1) ; Some(DiscreteRepeat(2,Some(p)))
            | None -> cursor := CC(0,0) ; None)
        | CC(n1,n2) ->
            (match (at !past n1), (at !past n2) with
            | Some(p1),Some(p2) ->
                cursor := CC(n1,n2+1) ;
                Some(Concat(p1,p2))
            | Some(p1), None ->
                cursor := CC(n1+1,0) ;
                None
            | _ ->
                cursor := CR(0) ;
                past := List.rev !next ;
                next := [] ;
                None)) in
        (match return with
        | Some(p) -> next := p::(!next) ; Some(p)
        | None -> None)

let rec generate_next : unit -> program =
    fun () -> (match generate_helper () with
    | Some(p) -> p
    | None -> generate_next ())
