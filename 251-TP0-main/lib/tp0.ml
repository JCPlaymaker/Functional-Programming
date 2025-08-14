(*Juan Carlos Merida Cortes: MERJ69080104 *)

(*Formatté avec ``dune fmt`` et ``ocamlformat``*)

(* Fonction qui crée une liste de caractères à partir d'un string donné en
   paramètre. *)
let explode (s : string) : char list = s |> String.to_seq |> List.of_seq

module Histogram = struct
  type t = (char * int) list

  (* Fonction qui permet d'ajouter un caractère à une liste si celle-ci
     n'existait pas auparavant. Si le caractère existait déjà, on augmente
     son compteur de 1. *)
  let add (histo : t) (c : char) : t =
    match histo with
    | [] -> [(c, 1)]
    | _ ->
        if List.exists (fun (d, _) -> d = c) histo then
          List.map (fun (d, i) -> if d = c then (d, i + 1) else (d, i)) histo
        else histo @ [(c, 1)]

  (* Fonction qui permet de convertir une chaîne de caractères en histogramme
     tout en le triant également. *)
  let of_string (s : string) : t =
    explode s |> List.fold_left add [] |> List.sort Stdlib.compare

  (* Fonction qui sert à comparer deux histogrammes. *)
  let compare (histo1 : t) (histo2 : t) : int = Stdlib.compare histo1 histo2
end

module HistogramMap = Map.Make (Histogram)

(* Fonction qui vérifie si deux strings sont des anagrammes. *)
let are_anagrams (s1 : string) (s2 : string) : bool =
  let h1 : Histogram.t = Histogram.of_string s1
  and h2 : Histogram.t = Histogram.of_string s2 in
  if Histogram.compare h1 h2 = 0 then true else false

(* Fonction qui trouve les anagrammes d'une liste de strings donnée en
   paramètre. *)
let find_anagrams (l : string list) : string list list =
  l
  |> List.fold_left
       (fun acc word ->
         let key = Histogram.of_string word in
         HistogramMap.update key
           (fun v ->
             Some (List.rev_append [word] (Option.value ~default:[] v)) )
           acc )
       HistogramMap.empty
  |> HistogramMap.bindings |> List.map snd
  |> List.filter (fun g -> List.length g > 1)
