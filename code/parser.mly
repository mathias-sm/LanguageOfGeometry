%token <float> FLOAT
%token <int> INT
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
%token EOF

%start <Interpreter.program option> program
%%
program:
    | EOF       { None }
    | v = value ; EOF { Some v }
;

value:
    | TURN ; BEGIN_ARGS ; f = FLOAT ; END_ARGS {Interpreter.Turn f}
    | SAVE ; BEGIN_ARGS ; s = STRING ; END_ARGS {Interpreter.Save s}
    | LOAD ; BEGIN_ARGS ; s = STRING ; END_ARGS {Interpreter.Load s}
    | DRAW ; BEGIN_ARGS ; f1 = FLOAT ; COMMA_ARGS ; f2 = FLOAT ; COMMA_ARGS ; f3
        = FLOAT ; COMMA_ARGS ; f4 = FLOAT ; END_ARGS
        {Interpreter.Draw(f1,f2,f3, f4)}
    | INTEGRATE ; BEGIN_ARGS ; f = FLOAT ; END_ARGS ; BEGIN_BLOCK ; p = value ;
        END_BLOCK {Interpreter.Integrate (f,p)}
    | p1 = value ; COLON ; p2 = value {Interpreter.Concat (p1,p2)}
    | DISCRETE_REPEAT ; BEGIN_ARGS ; n = INT ; END_ARGS ; BEGIN_BLOCK ; p = value ;
        END_BLOCK {Interpreter.DiscreteRepeat (n,p)}
