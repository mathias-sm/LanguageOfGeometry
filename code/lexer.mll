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
let alpha = ['a'-'z' 'A'-'Z']
let iden = alpha (alpha | digit | '_')*
let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"

rule read =
  parse
  | white    { read lexbuf }
  | newline  { next_line lexbuf; read lexbuf }
  | '"'      { read_string (Buffer.create 17) lexbuf }
  | '{'      { BEGIN_BLOCK }
  | '}'      { END_BLOCK }
  | '('      { BEGIN_ARGS }
  | ')'      { END_ARGS }
  | ';'      { COLON }
  | ','      { COMMA_ARGS }
  | '='      { EQUALS }
  | "Double" { DOUBLE }
  | "Half"   { HALF }
  | "Next"   { NEXT }
  | "Divide" { DIVIDE }
  | "Prev"   { PREV }
  | "Oppos"   { OPPOS }
  | "0" { ZERO }
  | "unit_distance"   { UNIT_DISTANCE }
  | "unit_angle"   { UNIT_ANGLE }
  | "unit_loop"   { UNIT_LOOP }
  | "unit_speed"   { UNIT_SPEED }
  | "unit_accel"   { UNIT_ACCEL }
  | "unit_angular_speed"   { UNIT_ANGULAR_SPEED }
  | "unit_angular_accel"   { UNIT_ANGULAR_ACCEL }
  | "Turn"   { TURN }
  | "Repeat"   { REPEAT }
  | "Integrate"   { INTEGRATE }
  | "SavePos"   { SAVE_POS }
  | "SaveStroke"   { SAVE_STROKE }
  | "LoadPos"   { LOAD_POS }
  | "LoadStroke"   { LOAD_STROKE }
  | "angle" { ARG_ANGLE }
  | "d" { ARG_D }
  | "pen" { ARG_PEN }
  | "on" { PEN (true) }
  | "off" { PEN (false) }
  | "speed" { ARG_SPEED }
  | "accel" { ARG_ACCEL }
  | "angularSpeed" { ARG_ANGULARSPEED }
  | "angularAccel" { ARG_ANGULARACCEL }
  | eof      { EOF }
  | iden as i  { VAR i }
  (*| _ { raise (SyntaxError ("unexpected char '" ^ Lexing.lexeme lexbuf ^ "'")) }*)

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

