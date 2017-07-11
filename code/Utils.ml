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

(* The relevant units *)

let unitLoop = 2
let unitDistance = pi2
let unitTurn = pis2
let baseSpeed = 1.
let baseAccel = 1.
let baseAngularSpeed = 1.
let baseAngularAccel = 1.
let defaultSpeed = 1.
let defaultAccel = 0.
let defaultAngularSpeed = 0.
let defaultAngularAccel = 0.
