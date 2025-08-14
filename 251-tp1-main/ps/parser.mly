%{
    let of_id (id : string) : Instr.t = match id with
      | "dup" -> Dup
      | "mul" -> Mul
      | "add" -> Add
      | "stack" -> Stack
      | "mod" -> Mod
      | "lt" -> Lt
      | "gt" -> Gt
      | "div" -> Div
      | "sub" -> Sub
      | "exch" -> Exch
      | "pop" -> Pop
      | "repeat" -> Repeat
      | "if" -> If
      | "ifelse" -> IfElse
      | "translate" -> Translate
      | "moveto" -> MoveTo
      | "rmoveto" -> RMoveTo
      | "lineto" -> LineTo
      | "rlineto" -> RLineTo
      | "stroke" -> Stroke
      | "rotate" -> Rotate
      | "def" -> Def
      | _ -> Var id
%}

%token <int> INT
%token <float> FLOAT
%token <string> ID
%token <string> REF
%token LBRACE
%token RBRACE
%token EOF

%start <Instr.t list> program
%%

program:
  | is = instrs; EOF; { is }

instrs:
  | is = instrs; i = instr; { is @ [i] }
  | { [] }

instr:
  | n = INT; { Int n }
  | n = FLOAT; { Float n }
  | LBRACE; is = instrs; RBRACE; { Procedure is }
  | i = ID; { of_id i }
  | s = REF; { Reference s }
