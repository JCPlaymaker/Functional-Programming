let _ =
  if Array.length Sys.argv <> 3 then
    Printf.printf "usage: %s input.ps output.png" (Array.get Sys.argv 0)
  else
    let input = Array.get Sys.argv 1 in
    let output = Array.get Sys.argv 2 in
    let result = Tp1.run input output in
    match result with
    | Ok output ->
      Printf.printf "----\nOUTPUT:\n----\n";
      List.iter (Printf.printf "%s\n") output
    | Error error ->
      Printf.printf "---\nERROR:\n----\n%s" error;
