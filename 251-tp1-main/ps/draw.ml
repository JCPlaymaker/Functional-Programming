type draw_action =
  | MoveTo of float * float
  | RMoveTo of float * float
  | LineTo of float * float
  | RLineTo of float * float
  | Translate of float * float
  | Rotate of float
  | Stroke

type t = draw_action list

let empty : t = []

let translate (draw : t) (tx : float) (ty : float) : t = (Translate (tx, ty)) :: draw
let rotate (draw : t) (angle : float) : t = (Rotate angle) :: draw
let stroke (draw : t) : t = Stroke :: draw
let move_to (draw : t) (x : float) (y : float) : t = (MoveTo (x, y)) :: draw
let rmove_to (draw : t) (x : float) (y : float) : t = (RMoveTo (x, y)) :: draw
let line_to (draw : t) (x : float) (y : float) : t = (LineTo (x, y)) :: draw
let rline_to (draw : t) (x : float) (y : float) : t = (RLineTo (x, y)) :: draw

let line_width : float = 2.
let output (draw : t) (path : string) : unit =
  let surface = Cairo.Image.create Cairo.Image.ARGB32 ~w:1000 ~h:1000 in
  let context = Cairo.create surface in
  Cairo.set_source_rgb context 0. 0. 0.;
  Cairo.move_to context 0. 0.;
  Cairo.set_line_width context line_width;
  let reflection_matrix = Cairo.Matrix.init_identity () in
  reflection_matrix.yy <- -1.;
  Cairo.set_matrix context reflection_matrix;
  Cairo.translate context 0. (-1000.);
  let do_action (action : draw_action) : unit =
    match action with
    | MoveTo (x, y) ->
      Cairo.move_to context x y
    | RMoveTo (x, y) ->
      Cairo.rel_move_to context x y
    | LineTo (x, y) ->
      Cairo.line_to context x y
    | RLineTo (x, y) ->
      Cairo.rel_line_to context x y
    | Translate (tx, ty) ->
      Cairo.translate context tx ty
    | Rotate angle ->
      Cairo.rotate context (angle *. (Float.pi /. 180.))
    | Stroke ->
      let (x, y) = Cairo.Path.get_current_point context in
      Cairo.stroke context;
      Cairo.move_to context x y;
  in
  List.iter do_action (List.rev draw);
  Cairo.PNG.write surface path
