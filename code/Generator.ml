open Interpreter

type cursor =
    | CC of int*int
    | CR of int
    | CSV1 | CSV2 | CSV3 (*| CSV4 *)
    | CL1 | CLP1 | CLS1 | CS1
    (*| CL2 | CLP2 | CLS2 | CS2*)
    | CT1
    | CION1 | CIOFF1
    (*| CION2 | CIOFF2*)
    (*| CION3 | CIOFF3*)

let rec at : program list -> int -> program option =
    fun l n -> match l with
    | e :: r -> if n = 0 then Some e else at r (n-1)
    | [] -> None

let generate_helper : unit -> program option =
    let past : program list ref = ref [] in
    let next : program list ref = ref [] in
    let cursor : cursor ref = ref CION1 in
    fun () ->
        let return : program option =
        (match !cursor with
        (*| CN -> cursor := CI ; Some(Nop)*)
        | CION1 -> cursor := CIOFF1 ; Some(Integrate(pi,true))
        | CIOFF1 -> cursor := CT1 ; Some(Integrate(pi,false))
        (*| CION2 -> cursor := CIOFF2 ; Some(Integrate(2.*.pi,true))*)
        (*| CIOFF2 -> cursor := CION3 ; Some(Integrate(2.*.pi,false))*)
        (*| CION3 -> cursor := CIOFF3 ; Some(Integrate(4.*.pi,true))*)
        (*| CIOFF3 -> cursor := CT1 ; Some(Integrate(4.*.pi,false))*)
        | CT1 -> cursor := CS1 ; Some(Turn(pi /. 4.))
        (*| CT2 -> cursor := CT3 ; Some(Turn(pi /. 2.))*)
        (*| CT3 -> cursor := CS1 ; Some(Turn(pi))*)
        | CS1 -> cursor := CLP1 ; Some(Save("a"))
        | CLP1 -> cursor := CLS1 ; Some(LoadPos("a"))
        | CLS1 -> cursor := CL1 ; Some(LoadStroke("a"))
        | CL1 -> cursor := CSV1 ; Some(Load("a"))
        (*| CS2 -> cursor := CLP2 ; Some(Save("b"))*)
        (*| CLP2 -> cursor := CLS2 ; Some(LoadPos("b"))*)
        (*| CLS2 -> cursor := CL2 ; Some(LoadStroke("b"))*)
        (*| CL2 -> cursor := CSV1 ; Some(Load("b"))*)
        | CSV1 -> cursor := CSV2 ; Some(SetValues(1.,0.,0.,0.))
        | CSV2 -> cursor := CSV3 ; Some(SetValues(1.,1.,0.,0.))
        | CSV3 -> cursor := CR(0) ; Some(SetValues(1.,1.,1.,0.))
        (*| CSV4 -> cursor := CR(0) ; Some(SetValues(1.,0.,0.,0.002))*)
        | CR(n) ->
            (match at !past n with
            | Some p -> cursor := CR(n+1) ; Some(DiscreteRepeat(2,p))
            | None -> cursor := CC(0,0) ; None)
        | CC(n1,n2) ->
            (match (at !past n1), (at !past n2) with
            | Some(p1),Some(p2) ->
                cursor := CC(n1+1,n2) ;
                Some(Concat(p1,p2))
            | None, Some(p2) ->
                cursor := CC(0,n2+1) ;
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

(*let simplify p =*)
    (*let rec helper p = match p with*)
    (*| Concat(Turn(_),p') -> helper p'*)
    (*| Concat(Integrate(_,false),p') -> helper p'*)
    (*| Concat(Integrate(_,true),_) -> p*)
    (*| Concat(DiscreteRepeat(n,p'),p2) ->*)
        (*let keep,p'' = helper_within p' in*)
        (*if keep then Concat(DiscreteRepeat(n,p''),p2) else p2*)
    (*| Concat(p1,p2) -> Concat(p1,helper p2)*)
    (*| _ -> p*)
    (*and helper_within p = match p with*)
        (*| Turn(_) -> false,Nop*)
        (*| Integrate(_,false) -> false,Nop*)
        (*| _ -> true,p*)
    (*in helper p*)
