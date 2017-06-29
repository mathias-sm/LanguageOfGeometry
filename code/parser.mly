%token <float> FLOAT
%token <string> STRING
%token <string> VAR
%token BEGIN_BLOCK
%token END_BLOCK
%token BEGIN_ARGS
%token COMMA_ARGS
%token END_ARGS
%token COLON
%token INTEGRATE
%token DISCRETE_REPEAT
%token SAVE
%token LOAD
%token TURN
%token PLUS
%token MINUS
%token TIMES
%token NOISE
%token DIV
%token EOF
%token SETVALUES
%token EQUALS
%token COMMENT

%start <((float)*Interpreter.program) option> program
%%
program:
    | EOF       { None }
    | n = noises ; v = value ; EOF { Some (n,v) }
;

expr:
    | f = FLOAT {f}
    | a = expr PLUS b = expr { a +. b }
    | a = expr MINUS b = expr { a -. b }
    | a = expr TIMES b = expr { a *. b }
    | a = expr DIV b = expr { a /. b }
    | MINUS b = expr { -. b }

noises:
    | {(0.001)}
    | NOISE EQUALS n=expr
      COLON {(n)}

value:
    | COMMENT ; _ = STRING { Interpreter.Nop }
    | TURN ; BEGIN_ARGS ; n = expr ; END_ARGS {Interpreter.Turn n}
    | SAVE ; BEGIN_ARGS ; s = STRING ; END_ARGS {Interpreter.Save s}
    | LOAD ; BEGIN_ARGS ; s = STRING ; END_ARGS {Interpreter.Load s}
    | SETVALUES ; BEGIN_ARGS ; END_ARGS {Interpreter.SetValues(1.,0.,0.,0.)}
    | SETVALUES ; BEGIN_ARGS ; var4 = VAR ; EQUALS ; n4 = expr ; END_ARGS
        {let vars = [var4] in
         let assoc = [var4,n4] in
         let m1 = (try List.assoc (List.find (String.equal "speed") vars) assoc
                   with Not_found -> 1.) in
         let m2 = (try List.assoc (List.find (String.equal "angularSpeed") vars) assoc
                   with Not_found -> 0.) in
         let m3 = (try List.assoc (List.find (String.equal "accel") vars) assoc
                   with Not_found -> 0.) in
         let m4 = (try List.assoc (List.find (String.equal "angularAccel") vars) assoc
                   with Not_found -> 0.) in
         Interpreter.SetValues(m1,m2,m3,m4)}
    | SETVALUES ; BEGIN_ARGS ;
        var3 = VAR ; EQUALS ; n3 = expr ; COMMA_ARGS
        var4 = VAR ; EQUALS ; n4 = expr ; END_ARGS
        {
         let vars = [var3;var4] in
         let assoc = [var3,n3;var4,n4] in
         let m1 = (try List.assoc (List.find (String.equal "speed") vars) assoc
                   with Not_found -> 1.) in
         let m2 = (try List.assoc (List.find (String.equal "angularSpeed") vars) assoc
                   with Not_found -> 0.) in
         let m3 = (try List.assoc (List.find (String.equal "accel") vars) assoc
                   with Not_found -> 0.) in
         let m4 = (try List.assoc (List.find (String.equal "angularAccel") vars) assoc
                   with Not_found -> 0.) in
         Interpreter.SetValues(m1,m2,m3,m4)}
    | SETVALUES ; BEGIN_ARGS ;
        var2 = VAR ; EQUALS ; n2 = expr ; COMMA_ARGS
        var3 = VAR ; EQUALS ; n3 = expr ; COMMA_ARGS
        var4 = VAR ; EQUALS ; n4 = expr ; END_ARGS
        {
         let vars = [var2;var3;var4] in
         let assoc = [var2,n2;var3,n3;var4,n4] in
         let m1 = (try List.assoc (List.find (String.equal "speed") vars) assoc
                   with Not_found -> 1.) in
         let m2 = (try List.assoc (List.find (String.equal "angularSpeed") vars) assoc
                   with Not_found -> 0.) in
         let m3 = (try List.assoc (List.find (String.equal "accel") vars) assoc
                   with Not_found -> 0.) in
         let m4 = (try List.assoc (List.find (String.equal "angularAccel") vars) assoc
                   with Not_found -> 0.) in
         Interpreter.SetValues(m1,m2,m3,m4)}
    | SETVALUES ; BEGIN_ARGS ;
        var1 = VAR; EQUALS ; n1 = expr ; COMMA_ARGS
        var2 = VAR ; EQUALS ; n2 = expr ; COMMA_ARGS
        var3 = VAR ; EQUALS ; n3 = expr ; COMMA_ARGS
        var4 = VAR ; EQUALS ; n4 = expr ; END_ARGS
        {
         let vars = [var1;var2;var3;var4] in
         let assoc = [var1,n1;var2,n2;var3,n3;var4,n4] in
         let m1 = (try List.assoc (List.find (String.equal "speed") vars) assoc
                   with Not_found -> 1.) in
         let m2 = (try List.assoc (List.find (String.equal "angularSpeed") vars) assoc
                   with Not_found -> 0.) in
         let m3 = (try List.assoc (List.find (String.equal "accel") vars) assoc
                   with Not_found -> 0.) in
         let m4 = (try List.assoc (List.find (String.equal "angularAccel") vars) assoc
                   with Not_found -> 0.) in
         Interpreter.SetValues(m1,m2,m3,m4)}
    | INTEGRATE ; BEGIN_ARGS ; n = expr ; END_ARGS
        {Interpreter.Integrate (n)}
    | p1 = value ; COLON ; p2 = value {Interpreter.Concat (p1,p2)}
    | DISCRETE_REPEAT ; BEGIN_ARGS ; n = expr ; END_ARGS ; BEGIN_BLOCK ; p = value ;
        END_BLOCK {Interpreter.DiscreteRepeat ((int_of_float n),(Some p))}
    | DISCRETE_REPEAT ; BEGIN_BLOCK ; p = value ; END_BLOCK
        {Interpreter.DiscreteRepeat (2,(Some p))}
    | DISCRETE_REPEAT ; BEGIN_ARGS ; n = expr ; END_ARGS ;
    BEGIN_BLOCK ; END_BLOCK
        {Interpreter.DiscreteRepeat ((int_of_float n),(Some Interpreter.Nop))}
    | DISCRETE_REPEAT ; BEGIN_BLOCK ; END_BLOCK
        {Interpreter.DiscreteRepeat (2,(Some Interpreter.Nop))}
