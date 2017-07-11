let moveto : float -> float -> unit =
    fun x y -> Graphics.moveto (int_of_float x) (int_of_float y)

let lineto : float -> float -> unit =
    fun x y -> Graphics.lineto (int_of_float x) (int_of_float y)

let middle_x () = ((float_of_int (Graphics.size_x ())) /. 2.)
let middle_y () = ((float_of_int (Graphics.size_y ())) /. 2.)
