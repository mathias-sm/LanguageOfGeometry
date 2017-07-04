open Interpreter

type cursor =
    | CC of int*int
    | CR of int
    | CSV1 | CSV2 | CSV3 (*| CSV4 *)
    | CL1 | CLP1 | CLS1 | CS1
    (*| CL2 | CLP2 | CLS2 | CS2*)
    | CT | CION | CIOFF (*| CN *)

let rec at : program list -> int -> program option =
    fun l n -> match l with
    | e :: r -> if n = 0 then Some e else at r (n-1)
    | [] -> None

let generate_helper : unit -> program option =
    let past : program list ref = ref [] in
    let next : program list ref = ref [] in
    let cursor : cursor ref = ref CION in
    fun () ->
        let return : program option =
        (match !cursor with
        (*| CN -> cursor := CI ; Some(Nop)*)
        | CION -> cursor := CIOFF ; Some(Integrate(50.,true))
        | CIOFF -> cursor := CT ; Some(Integrate(50.,false))
        | CT -> cursor := CS1 ; Some(Turn(pi /. 2.))
        | CS1 -> cursor := CLP1 ; Some(Save("a"))
        | CLP1 -> cursor := CLS1 ; Some(LoadPos("a"))
        | CLS1 -> cursor := CL1 ; Some(LoadStroke("a"))
        | CL1 -> cursor := CSV1 ; Some(Load("a"))
        (*| CS2 -> cursor := CLP2 ; Some(Save("b"))*)
        (*| CLP2 -> cursor := CLS2 ; Some(LoadPos("b"))*)
        (*| CLS2 -> cursor := CL2 ; Some(LoadStroke("b"))*)
        (*| CL2 -> cursor := CSV1 ; Some(Load("b"))*)
        | CSV1 -> cursor := CSV2 ; Some(SetValues(1.,0.,0.,0.))
        | CSV2 -> cursor := CSV3 ; Some(SetValues(1.,pi/.25.,0.,0.))
        | CSV3 -> cursor := CR(0) ; Some(SetValues(1.,0.3,0.3,0.))
        (*| CSV4 -> cursor := CR(0) ; Some(SetValues(1.,0.,0.,0.002))*)
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
