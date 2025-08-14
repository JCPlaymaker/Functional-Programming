(* Juan Carlos Merida Cortes: MERJ69080104 *)
open Tp1_ps

(* Erreurs: Comme je n'ai pas vraiment eu le temps de finir, la gestion des erreurs a été fait de sorte 
 * que chaque fois qu'on match quelque chose qui ne devrait pas être, on renvoie une liste vide,
 * comme si le cas n'avait pas été évalué.
 *
 * Résultats stack: En ce qui concerne la gestion des Résultats affichés par stack, ceci est fait en 
 * utilisant deux listes, une qui agit comme un vrai stack et l'autre qui agit comme un accumulateur.
 * Une fois qu'une ligne a été traitée, on transforme le contenu du stack en string et les strings sont 
 * envoyés sur l'accumulateur qui ensuite affichera son contenu.
 * 
 * Fonction Ordre Sup.:  Une fonction d'ordre supérieur est utilisée dans la fonction `run`, où `List.map`
 * sert à convertir les éléments de la pile en chaînes de caractères pour l'affichage.
 * Cela permet d'éviter à faire des loops manuellement.
 *
 * Fold : L'opérateur `List.fold_left` est utilisé pour exécuter une séquence d'instructions dans
 * l’évaluation des procédures ou dans `run`.
 * Il permet de propager l'état (pile + sortie) à travers chaque instruction. On applique les instructions
 * une par une sur un état accumulé.
 *)


(* Hashtable pour faire mes définitions de références (accorder des valeurs comme avec des variables) *)
(* Inspiré des vidéos de Clarkson *)
let env : (string, Instr.t) Hashtbl.t = Hashtbl.create 32

(* Convertir une instruction en string pour affichage *)
let rec string_of_instr (instr : Instr.t) : string =
  match instr with
  | Instr.Int (-10) -> "true"
  | Instr.Int (-20) -> "false"
  | Instr.Int i -> string_of_int i
  | Instr.Float f -> Printf.sprintf "%.2f" f
  | Instr.Procedure prog -> 
      let content = List.map string_of_instr prog |> String.concat " " in
      Printf.sprintf "{ %s }" content
  | Instr.Reference ref -> ref
  | _ -> ""

(* === Handlers pour chaque instruction === *)

(* Gérer une instruction Int *)
let handle_int (i : int) (stack : Instr.t list) : Instr.t list =
  Instr.Int i :: stack

(* Gérer une instruction Float *)
let handle_float (f : float) (stack : Instr.t list) : Instr.t list =
  Instr.Float f :: stack

(* Gérer la duplication de la valeur au sommet de la pile *)
let handle_dup (stack : Instr.t list) : Instr.t list =
  match stack with
  | x :: reste -> x :: x :: reste
  | [] -> []

(* Gérer la suppression du sommet de la pile *)
let handle_pop (stack : Instr.t list) : Instr.t list =
  match stack with
  | _ :: reste -> reste
  | [] -> []

(* Gérer l'échange des deux premiers éléments de la pile *)
let handle_exch (stack : Instr.t list) : Instr.t list =
  match stack with
  | a :: b :: reste -> b :: a :: reste
  | _ -> []

(* Gérer l'addition des deux premiers éléments de la pile *)
let handle_add (stack : Instr.t list) : Instr.t list =
  match stack with
  | Instr.Int a :: Instr.Int b :: reste ->
      Instr.Int (a + b) :: reste
  | Instr.Float a :: Instr.Float b :: reste ->
      Instr.Float (a +. b) :: reste
  | Instr.Int a :: Instr.Float b :: reste ->
      Instr.Float (float_of_int a +. b) :: reste
  | Instr.Float a :: Instr.Int b :: reste ->
      Instr.Float (a +. float_of_int b) :: reste
  | _ -> []
(* Gérer la soustraction des deux premiers éléments de la pile *)
let handle_sub (stack : Instr.t list) : Instr.t list =
  match stack with
  | Instr.Int a :: Instr.Int b :: reste ->
      Instr.Int (b - a) :: reste
  | Instr.Float a :: Instr.Float b :: reste ->
      Instr.Float (b -. a) :: reste
  | Instr.Int a :: Instr.Float b :: reste ->
      Instr.Float (b -. float_of_int a) :: reste
  | Instr.Float a :: Instr.Int b :: reste ->
      Instr.Float (float_of_int b -. a) :: reste
  | _ -> []

(* Gérer la multiplication des deux premiers éléments de la pile *)
let handle_mul (stack : Instr.t list) : Instr.t list =
  match stack with
  | Instr.Int a :: Instr.Int b :: reste ->
      Instr.Int (a * b) :: reste
  | Instr.Float a :: Instr.Float b :: reste ->
      Instr.Float (a *. b) :: reste
  | Instr.Int a :: Instr.Float b :: reste ->
      Instr.Float (float_of_int a *. b) :: reste
  | Instr.Float a :: Instr.Int b :: reste ->
      Instr.Float (a *. float_of_int b) :: reste
  | _ -> []

(* Gérer la division des deux premiers éléments de la pile *)
let handle_div (stack : Instr.t list) : Instr.t list =
  match stack with
  | Instr.Int a :: Instr.Int b :: reste ->
      if a = 0 then []
      else Instr.Float (float_of_int b /. float_of_int a) :: reste
  | Instr.Float a :: Instr.Float b :: reste ->
      if a = 0. then []
      else Instr.Float (b /. a) :: reste
  | Instr.Int a :: Instr.Float b :: reste ->
      if a = 0 then []
      else Instr.Float (b /. float_of_int a) :: reste
  | Instr.Float a :: Instr.Int b :: reste ->
      if a = 0. then []
      else Instr.Float (float_of_int b /. a) :: reste
  | _ -> []

(* Gérer la comparaison "plus petit que" des deux premiers éléments sur la pile *)
let handle_lt (stack : Instr.t list) : Instr.t list =
  match stack with
  | Instr.Int a :: Instr.Int b :: reste ->
      let resultat = if b < a then -10 else -20 in
      Instr.Int resultat :: reste
  | _ -> []

(* Gérer la comparaison "plus grand que" des deux premiers éléments sur la pile *)
let handle_gt (stack : Instr.t list) : Instr.t list =
  match stack with
  | Instr.Int a :: Instr.Int b :: reste ->
      let resultat = if b > a then -10 else -20 in
      Instr.Int resultat :: reste
  | _ -> []

(* Gérer l'operation du modulo *)
let handle_mod (stack : Instr.t list) : Instr.t list =
  match stack with
  | Instr.Int a :: Instr.Int b :: reste ->
      if a = 0 then []
      else Instr.Int (b mod a) :: reste
  | _ -> []

(* Gérer l'empilement d'une procédure *)
let handle_procedure (p : Instr.program) (stack : Instr.t list) : Instr.t list =
  Instr.Procedure p :: stack

(* Gérer l'introduction des références sur la pile *)
let handle_reference (ref : string) (stack : Instr.t list) : Instr.t list =
  Instr.Reference ref :: stack

(* Gérer les définitions de références *)
let handle_def (stack : Instr.t list) : Instr.t list =
  match stack with
  | valeur :: Instr.Reference ref :: reste ->
      Hashtbl.replace env ref valeur;
      reste
  | _ -> []


(* Gérer l'affichage de la pile *)
(* Retourne une string list contenant une seule string bien formatée *)
let handle_stack (stack : Instr.t list) (soutput : string list) : Instr.t list * string list =
  let ligne = List.map string_of_instr stack |> String.concat " " in
  let formatted = Printf.sprintf "[ %s ]" ligne in
  (stack, soutput @ [formatted])

(* Exécuter une instruction et retourner la nouvelle pile et la sortie *)
let rec eval_instr ((stack, soutput) : Instr.t list * string list) (instr : Instr.t) : Instr.t list * string list =
  match instr with
  | Instr.Int i -> (handle_int i stack, soutput)
  | Instr.Float f -> (handle_float f stack, soutput)
  | Instr.Dup -> (handle_dup stack, soutput)
  | Instr.Pop -> (handle_pop stack, soutput)
  | Instr.Exch -> (handle_exch stack, soutput)
  | Instr.Add -> (handle_add stack, soutput)
  | Instr.Sub -> (handle_sub stack, soutput)
  | Instr.Mul -> (handle_mul stack, soutput)
  | Instr.Div -> (handle_div stack, soutput)
  | Instr.Lt -> (handle_lt stack, soutput)
  | Instr.Gt -> (handle_gt stack, soutput)
  | Instr.Mod -> (handle_mod stack, soutput)
  | Instr.Stack -> handle_stack stack soutput
  | Instr.Procedure p -> (handle_procedure p stack, soutput)
  | Instr.Repeat -> handle_repeat stack soutput
  | Instr.If -> handle_if stack soutput
  | Instr.IfElse -> handle_ifelse stack soutput
  | Instr.Reference ref -> (handle_reference ref stack, soutput)
  | Instr.Def -> (handle_def stack, soutput)
  | Instr.Var name -> resolve_var name stack soutput
  | _ -> (stack, soutput)

(* Gérer le nombre de répétitions qu'une procédure sera invoquée consécutivement *)
and handle_repeat (stack : Instr.t list) (soutput : string list) : Instr.t list * string list =
  match stack with
  | Instr.Procedure p :: Instr.Int n :: reste ->
      let rec repeter_eval fois acc_stack acc_output =
        if fois <= 0 then (acc_stack, acc_output)
        else
          let new_stack, new_output =
            List.fold_left eval_instr (acc_stack, acc_output) p
          in
          repeter_eval (fois - 1) new_stack new_output
      in
      repeter_eval n reste soutput
  | _ -> [],[]

(* Gérer l'embranchement créé par une instruction if sur une procédure *)
and handle_if (stack : Instr.t list) (soutput : string list) : Instr.t list * string list =
  match stack with
  | Instr.Procedure p :: Instr.Int cond :: reste ->
    if cond = -10 then
      List.fold_left eval_instr (reste, soutput) p
    else
      (reste, soutput)
  | _ -> [], []

(* Gérer l'embranchement créé par une instruction ifelse sur deux procédures *)
and handle_ifelse (stack : Instr.t list) (soutput : string list) : Instr.t list * string list =
  match stack with
  | Instr.Procedure p2 :: Instr.Procedure p1 :: Instr.Int cond :: reste ->
      let choisi = if cond = -10 then p1 else p2 in
      List.fold_left eval_instr (reste, soutput) choisi
  | _ -> [], []

(* Résout une variable selon ce qui est rangé dans le hashtable
 * #1 Si la variable est associée à une procédure, on exécute la procédure
 * #2 Si elle est associée à une simple valeur, on empile sur la pile
 * #3 Sinon, échec
 *)
and resolve_var (name : string) (stack : Instr.t list) (soutput : string list)
  : Instr.t list * string list =
  match Hashtbl.find_opt env name with
  | Some (Instr.Procedure p) ->
      List.fold_left eval_instr (stack, soutput) p
  | Some value ->
      (value :: stack, soutput)
  | None -> [], []

  (* Fonction principale qui exécute tout le programme *)
let run (input : string) (output : string) : (string list, string) result =
  let program = Utils.parse input in
  let (_final_stack, all_output) =
    List.fold_left eval_instr ([], []) program
  in
  ignore output;
  Ok all_output

