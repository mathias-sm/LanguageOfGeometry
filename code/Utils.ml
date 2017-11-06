open Vg
open Gg

(* Some utils values and functions *)

let pi = 4. *. atan(1.)
let pi2 = 2. *. pi
let pi4 = 4. *. pi
let pis2 = pi /. 2.
let pis4 = pi /. 4.

let my_print_float f = match f with
 | f when f = pi4  -> "4*π"
 | f when f = pi2  -> "2*π"
 | f when f = pi  -> "π"
 | f when f = pis2 -> "π/2"
 | f when f = pis4 -> "π/4"
 | f when f = (-1.) *. pi4  -> "-4*π"
 | f when f = (-1.) *. pi2  -> "-2*π"
 | f when f = (-1.) *. pi  -> "-π"
 | f when f = (-1.) *. pis2 -> "-π/2"
 | f when f = (-1.) *. pis4 -> "-π/4"
 | _ -> Printf.sprintf "%.4g" f

let my_print_bool b = match b with
 | true -> "on"
 | false -> "off"

let normal_random () =
    let u1 = Random.float 1. and u2 = Random.float 1. in
    (sqrt ((-2.) *. (log u1) )) *. (cos (2. *. pi *. u2))

let get_infos ?smart:(smart=true) d_from_origin box canvas =
    let d2 = 384. in
    let view_crop =
        try (Gg.Box2.inter
                box
                (Gg.Box2.v (Gg.P2.v 0. 0.) (Gg.Size2.v d2 d2)))
        with Invalid_argument(_) -> Gg.Box2.empty
    in
    let s = Gg.Box2.size view_crop in
    let o = Gg.Box2.o view_crop in
    let dim = max (Gg.P2.x s) (Gg.P2.y s) in
    let offsetx = (Gg.P2.x s -. dim) /. 2. in
    let offsety = (Gg.P2.y s -. dim) /. 2. in
    let view = if smart then (Gg.Box2.v
        (Gg.P2.v (Gg.P2.x o +. offsetx -. 0.2) (Gg.P2.y o +. offsety -. 0.2))
        (Gg.P2.v (dim +. 0.4) (dim +. 0.4)))
    else (Gg.Box2.v (Gg.P2.v 0. 0.) (Gg.Size2.v d2 d2)) in
    let barycenter = Gg.Box2.mid view in
    let boxFinalSize = d2 /. 6. in
    let view = Gg.Box2.v_mid barycenter (Gg.Size2.v boxFinalSize boxFinalSize) in
    (*let size = Size2.v (d_from_origin +. maxdim) (d_from_origin +. maxdim) in*) 
    let size = Size2.v d2 d2 in
    let area = `O { P.o with P.width = 1. /. 2. } in
    let black = I.const Color.black in
    let image = I.cut ~area canvas black in
    (view,size,image)
