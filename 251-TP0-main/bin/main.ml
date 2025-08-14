(** [read_file path] reads the file at [path] and returns its lines as a list *)
let read_file (filename : string) : string list =
  let lines = ref [] in
  let chan = open_in filename in
  try
    while true do
      lines := input_line chan :: !lines
    done ;
    !lines
  with End_of_file -> close_in chan ; List.rev !lines

(** [timeit f] calls [f ()] and prints the time needed to execute it *)
let timeit (f : unit -> 'a) : 'a =
  let t = Sys.time () in
  let res = f () in
  Printf.printf "Done in %fs\n" (Sys.time () -. t) ;
  res

(** This is the entry point. It reads th *)
let _ =
  if Array.length Sys.argv <> 2 then
    Printf.eprintf "usage: %s file.txt" Sys.argv.(0)
  else
    let argument = Sys.argv.(1) in
    timeit (fun () ->
        read_file argument |> Tp0.find_anagrams
        |> List.iter (fun l ->
               Printf.printf "%d: %s\n%!" (List.length l)
                 (String.concat "," l) ) )
