%token <float> FLOAT
%token <int> INT
%token <Interpreter.program * Interpreter.program> CONCAT
%token BEGIN_BLOCK
%token END_BLOCK
%token BEGIN_ARGS
%token COMMA_ARGS
%token END_ARGS
%token <string> SAVE
%token <string> LOAD
%token <float> TURN
%token <float*Interpreetr.program> INTEGRATE
%token <int*Interpreter.program> DISCRETE_REPEAT
%token <float*float*float> DRAW
%token EOF

%start <Interpreter.program option> program
%%
prog:
    | EOF       { None }
    | v = value { Some v }
;

value:
    | s = SAVE {Save s}
    | s = LOAD {Load s}
