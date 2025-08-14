{
  open Parser
  exception Error of string
  let drop_first_char (s : string) : string =
    String.sub s 1 (String.length s - 1)
}

let digit = ['0'-'9']
let int = '-'? digit+
let exp = ['e' 'E'] ['-' '+']? digit+
let float = '-'? digit* '.' digit* exp?

let id = ['a'-'z' 'A'-'Z']+ ['a'-'z' 'A'-'Z' '0'-'9' '_']*
let ref = '/' id

let comment = '%' [^'\n']*

rule lexeme = parse
  | [' ' '\t' '\r'] { lexeme lexbuf }
  | comment { lexeme lexbuf }
  | '\n' { Lexing.new_line lexbuf; lexeme lexbuf }
  | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | float { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | id { ID (Lexing.lexeme lexbuf) }
  | ref { REF (drop_first_char (Lexing.lexeme lexbuf)) }
  | '{' { LBRACE }
  | '}' { RBRACE }
  | _ as c { raise (Error (Printf.sprintf "Unexpected character: %c" c)) }
  | eof { EOF }
