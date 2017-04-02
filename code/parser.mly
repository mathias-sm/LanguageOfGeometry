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
%token SET
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
    | SET ; BEGIN_ARGS ; f1 = FLOAT ; COMMA_ARGS ; f2 = FLOAT ; END_ARGS
        {Interpreter.Set(f1,f2)}
    | DRAW ; BEGIN_ARGS ; f1 = FLOAT ; COMMA_ARGS ; f2 = FLOAT ; END_ARGS
        {Interpreter.Draw(f1,f2)}
    | INTEGRATE ; BEGIN_ARGS ; f = FLOAT ; END_ARGS ; BEGIN_BLOCK ; END_BLOCK
        {Interpreter.Integrate (f,None)}
    | INTEGRATE ; BEGIN_ARGS ; f = FLOAT ; END_ARGS ; BEGIN_BLOCK ; p = value ;
        END_BLOCK {Interpreter.Integrate (f,(Some p))}
    | p1 = value ; COLON ; p2 = value {Interpreter.Concat (p1,p2)}
    | DISCRETE_REPEAT ; BEGIN_ARGS ; n = INT ; END_ARGS ; BEGIN_BLOCK ; p = value ;
        END_BLOCK {Interpreter.DiscreteRepeat (n,(Some p))}
    | DISCRETE_REPEAT ; BEGIN_ARGS ; n = INT ; END_ARGS ; BEGIN_BLOCK ;
        END_BLOCK {Interpreter.DiscreteRepeat (n,None)}
