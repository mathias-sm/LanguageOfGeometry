%token <float> FLOAT
%token <string> STRING
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
%token DRAW
%token PLUS
%token MINUS
%token TIMES
%token DIV
%token SET
%token EOF

%start <Interpreter.program option> program
%%
program:
    | EOF       { None }
    | v = value ; EOF { Some v }
;

expr:
    | f = FLOAT {f}
    | a = expr PLUS b = expr { a +. b }
    | a = expr MINUS b = expr { a -. b }
    | a = expr TIMES b = expr { a *. b }
    | a = expr DIV b = expr { a /. b }
    | MINUS b = expr { -. b }

value:
    | TURN ; BEGIN_ARGS ; n = expr ; END_ARGS {Interpreter.Turn n}
    | SAVE ; BEGIN_ARGS ; s = STRING ; END_ARGS {Interpreter.Save s}
    | LOAD ; BEGIN_ARGS ; s = STRING ; END_ARGS {Interpreter.Load s}
    | SET ; BEGIN_ARGS ; n1 = expr ; COMMA_ARGS ; n2 = expr ; END_ARGS
        {Interpreter.Set(n1,n2)}
    | DRAW ; BEGIN_ARGS ; n1 = expr ; COMMA_ARGS ; n2 = expr ; END_ARGS
        {Interpreter.Draw(n1,n2)}
    | INTEGRATE ; BEGIN_ARGS ; n = expr ; END_ARGS ; BEGIN_BLOCK ; END_BLOCK
        {Interpreter.Integrate (n,None)}
    | INTEGRATE ; BEGIN_ARGS ; n = expr ; END_ARGS ; BEGIN_BLOCK ; p = value ;
        END_BLOCK {Interpreter.Integrate (n,(Some p))}
    | p1 = value ; COLON ; p2 = value {Interpreter.Concat (p1,p2)}
    | DISCRETE_REPEAT ; BEGIN_ARGS ; n = expr ; END_ARGS ; BEGIN_BLOCK ; p = value ;
        END_BLOCK {Interpreter.DiscreteRepeat ((int_of_float n),(Some p))}
    | DISCRETE_REPEAT ; BEGIN_ARGS ; n = expr ; END_ARGS ; BEGIN_BLOCK ;
        END_BLOCK {Interpreter.DiscreteRepeat ((int_of_float n),None)}
