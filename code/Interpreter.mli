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

exception MalformedProgram of string

val pp_program : out_channel -> program -> unit

val valuesCostVar : var -> int

val valuesCostProgram : program -> int

val costProgram : program -> int

val interpret : program -> float -> unit
