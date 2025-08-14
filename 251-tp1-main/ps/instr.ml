type t =
  | Int of int
  | Float of float
  | Stack

  | Dup
  | Exch
  | Pop

  | Add
  | Mul
  | Div
  | Sub
  | Mod
  | Lt
  | Gt

  | Procedure of t list
  | Repeat
  | If
  | IfElse

  | Translate
  | Rotate
  | MoveTo
  | RMoveTo
  | LineTo
  | RLineTo
  | Stroke

  | Reference of string
  | Def
  | Var of string

type program = t list
