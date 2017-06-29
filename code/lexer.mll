{
open Lexing
open Parser

exception SyntaxError of string

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }
}

let digit = ['0'-'9']
let frac = '.' digit*
let float = digit* frac?

let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"

rule read =
  parse
  | white    { read lexbuf }
  | newline  { next_line lexbuf; read lexbuf }
  | float    { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | '"'      { read_string (Buffer.create 17) lexbuf }
  | '{'      { BEGIN_BLOCK }
  | '}'      { END_BLOCK }
  | '('      { BEGIN_ARGS }
  | ')'      { END_ARGS }
  | '+'      { PLUS }
  | '-'      { MINUS }
  | '*'      { TIMES }
  | '/'      { DIV }
  | ','      { COMMA_ARGS }
  | ';'      { COLON }
  | '='      { EQUALS }
  | '#'      { COMMENT }
  | "pi"     { FLOAT (3.14159265359) }
  | "π"      { FLOAT (3.14159265359) }
  | "Turn"   { TURN }
  | "SetValues" {SETVALUES}
  | "DiscreteRepeat"   { DISCRETE_REPEAT }
  | "Integrate"   { INTEGRATE }
  | "DiscreteRepeat"   { DISCRETE_REPEAT }
  | "Save"   { SAVE }
  | "Load"   { LOAD }
  | "NOISE"  {NOISE}
  | "speed"     { VAR "speed" }
  | "angularSpeed"     { VAR "angularSpeed" }
  | "accel"    { VAR "accel" }
  | "angularAccel"    { VAR "angularAccel" }
  | eof      { EOF }
  | _ { raise (SyntaxError ("unexpected char '" ^ Lexing.lexeme lexbuf ^ "'")) }

and read_string buf =
  parse
  | '"'       { STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | [^ '"' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_string buf lexbuf
    }
  | _ { raise (SyntaxError ("Illegal string character: " ^ Lexing.lexeme lexbuf)) }
  | eof { raise (SyntaxError ("String is not terminated")) }

