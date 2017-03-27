open Graphics
open Interpreter

let () =
    let simpleLine = Integrate(200., Draw(1.,0.,0.)) in
    let square =
        DiscreteRepeat(4,
            Turn(pi2) ++ Integrate(20., Draw(1., 0., 0.))) in
    let test =
           Save "cou"
        ++ Integrate(20., Draw(1., 0.05, 0.))
        ++ Load "cou"
        ++ Turn((-1.) *. pi2)
        ++ Integrate(5., Draw(1., 0., 0.))
        ++ Save "torse"
        ++ Integrate(5., Draw(1., 0., 0.))
        ++ Save "jambes"
        ++ Turn(pi4)
        ++ Integrate(5., Draw(1., 0., 0.))
        ++ Load "jambes"
        ++ Turn((-1.) *. pi4)
        ++ Integrate(5., Draw(1., 0., 0.))
        ++ Load "torse"
        ++ Turn(pi2)
        ++ Integrate(5., Draw(1., 0., 0.))
        ++ Load "torse"
        ++ Turn((-1.)*.pi2)
        ++ Integrate(5., Draw(1., 0., 0.))
    in
    pp_program simpleLine ;
    pp_program square ;
    pp_program test ;
    open_graph "" ;
    moveto (size_x () / 2) (size_y () / 2) ;
    interpret test ;
    Unix.sleep 5 ;
