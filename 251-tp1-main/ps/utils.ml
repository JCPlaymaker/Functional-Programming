let position_to_string (lexbuf : Lexing.lexbuf) : string =
  let pos = lexbuf.Lexing.lex_curr_p in
  Printf.sprintf "Line %d, column %d" pos.Lexing.pos_lnum (pos.Lexing.pos_cnum - pos.Lexing.pos_bol)

let parse (path : string) : Instr.program =
  let ic = open_in path in
  let lexbuf = Lexing.from_channel ic in
  try
    let result = Parser.program Lexer.lexeme lexbuf in
    close_in ic;
    result
  with
  | Lexer.Error msg ->
      close_in ic;
      Printf.eprintf "Lexer error at %s: %s\n" (position_to_string lexbuf) msg;
      exit 1
  | Parser.Error ->
      close_in ic;
      let pos = position_to_string lexbuf in
      let token = Lexing.lexeme lexbuf in
      Printf.eprintf "Parser error at %s: unexpected token '%s'\n" pos token;
      exit 1

