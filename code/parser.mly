%token <string> STRING
%token <bool> PEN
%token <string> VAR
%token BEGIN_BLOCK
%token END_BLOCK
%token BEGIN_ARGS
%token END_ARGS
%token COLON
%left COLON
%token INTEGRATE
%token REPEAT
%token SAVE_POS
%token SAVE_STROKE
%token LOAD_POS
%token LOAD_STROKE
%token TURN
%token DOUBLE
%token HALF
%token NEXT
%token PREV
%token OPPOS
%token DIVIDE
%token UNIT_TIME
%token UNIT_ANGLE
%token UNIT_LOOP
%token UNIT_SPEED
%token UNIT_ACCEL
%token UNIT_ANGULAR_SPEED
%token UNIT_ANGULAR_ACCEL
%token ZERO
%token COMMA_ARGS
%token ARG_ANGLE
%token ARG_T
%token ARG_PEN
%token ARG_SPEED
%token ARG_ACCEL
%token ARG_ANGULARSPEED
%token ARG_ANGULARACCEL
%token EQUALS
%token EOF

%start <((float)*Interpreter.program) option> program
%%
program:
    | EOF       { None }
    | v = value ; EOF { Some (0.,v) }
;

optional_comma:
    | COMMA_ARGS {}
    | {}

expr:
  | UNIT_TIME { Interpreter.UnitTime }
  | ZERO { Interpreter.Zero }
  | UNIT_ANGLE { Interpreter.UnitAngle }
  | UNIT_LOOP { Interpreter.UnitLoop }
  | UNIT_SPEED { Interpreter.UnitSpeed }
  | UNIT_ACCEL { Interpreter.UnitAccel }
  | UNIT_ANGULAR_SPEED { Interpreter.UnitAngularSpeed }
  | UNIT_ANGULAR_ACCEL { Interpreter.UnitAngularAccel }
  | DOUBLE ; BEGIN_ARGS ; e = expr ; END_ARGS {Interpreter.Double (e) }
  | HALF ; BEGIN_ARGS ; e = expr ; END_ARGS {Interpreter.Half (e) }
  | NEXT ; BEGIN_ARGS ; e = expr ; END_ARGS {Interpreter.Next (e) }
  | DIVIDE ; BEGIN_ARGS ; e1 = expr ; COMMA_ARGS ; e2 = expr ; END_ARGS
    {Interpreter.Divide (e1,e2) }
  | PREV ; BEGIN_ARGS ; e = expr ; END_ARGS {Interpreter.Prev (e) }
  | OPPOS ; BEGIN_ARGS ; e = expr ; END_ARGS {Interpreter.Oppos (e) }
  | s = VAR { Interpreter.Name s }

optional_turn_args:
    | BEGIN_ARGS ; ARG_ANGLE ; EQUALS ; e = expr ; END_ARGS {Some e}
    | BEGIN_ARGS ; END_ARGS {None}
    | {None}
turn:
    | TURN ; args = optional_turn_args ; {Interpreter.Turn args}


optional_repeat_args:
    | BEGIN_ARGS ; e = expr ; END_ARGS { Some e }
    | {None}
repeat:
    | REPEAT ; n = optional_repeat_args ; BEGIN_BLOCK ; p = value ; END_BLOCK
        {Interpreter.Repeat (n,p)}


optional_integrate_args:
    | BEGIN_ARGS ;
        d = optional_integrate_d ; optional_comma ;
        pen = optional_integrate_pen ; optional_comma ;
        speed = optional_integrate_speed ; optional_comma ;
        accel = optional_integrate_accel ; optional_comma ;
        angularSpeed = optional_integrate_angularSpeed ; optional_comma ;
        angularAccel = optional_integrate_angularAccel ;
        END_ARGS
        {Interpreter.Integrate (d,pen,(speed,accel,angularSpeed,angularAccel))}
    | { Interpreter.Integrate (None,None,(None,None,None,None)) }
optional_integrate_d:
    | ARG_T ; EQUALS ; e = expr { Some e }
    | {None}
optional_integrate_pen:
    | ARG_PEN ; EQUALS ; b = PEN { Some b }
    | {None}
optional_integrate_speed:
    | ARG_SPEED ; EQUALS ; e = expr { Some e }
    | {None}
optional_integrate_accel:
    | ARG_ACCEL ; EQUALS ; e = expr { Some e }
    | {None}
optional_integrate_angularSpeed:
    | ARG_ANGULARSPEED ; EQUALS ; e = expr { Some e }
    | {None}
optional_integrate_angularAccel:
    | ARG_ANGULARACCEL ; EQUALS ; e = expr { Some e }
    | {None}
integrate:
    | INTEGRATE ;
        i = optional_integrate_args { i }

value:
    | t = turn { t }
    | SAVE_POS ; BEGIN_ARGS ; s = STRING ; END_ARGS {Interpreter.SavePos s}
    | SAVE_STROKE ; BEGIN_ARGS ; s = STRING ; END_ARGS {Interpreter.SaveStroke s}
    | LOAD_POS ; BEGIN_ARGS ; s = STRING ; END_ARGS {Interpreter.LoadPos s}
    | LOAD_STROKE ; BEGIN_ARGS ; s = STRING ; END_ARGS {Interpreter.LoadStroke s}
    | p1 = value ; COLON ; p2 = value {Interpreter.Concat (p1,p2)}
    | s = VAR ; EQUALS ; e = expr {Interpreter.Define (s,e)}
    | r = repeat { r }
    | i = integrate { i }
