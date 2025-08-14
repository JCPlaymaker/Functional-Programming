open Tp0

let%test "explode" = explode "foo" = ['f'; 'o'; 'o']

let%test "explode empty" = explode "" = []

let empty_histogram = []

let%test "Histogram.add 1" = Histogram.add empty_histogram 't' = [('t', 1)]

let%test "Histogram.add 2" =
  Histogram.add (Histogram.add empty_histogram 't') 'r' = [('t', 1); ('r', 1)]

let%test "Histogram.add 3" =
  Histogram.add (Histogram.add empty_histogram 't') 't' = [('t', 2)]

let%test "Histogram.of_string tri" =
  Tp0.Histogram.of_string "tri" = [('i', 1); ('r', 1); ('t', 1)]

let%test "Histogram.of_string rit" =
  Tp0.Histogram.of_string "rit" = [('i', 1); ('r', 1); ('t', 1)]

let%test "Histogram.of_string equality" =
  Tp0.Histogram.of_string "tri" = Histogram.of_string "rit"

let%test "Histogram.of_string empty" =
  Tp0.Histogram.of_string "" = empty_histogram

let%test "Histogram.of_string duplicates" =
  Histogram.of_string "foo" = [('f', 1); ('o', 2)]

let%test "Histogram.compare empty" = Histogram.compare [] [] = 0

let%test "Histogram.compare" = Histogram.compare [('a', 1)] [('b', 1)] = -1

let%test "Histogram.compare" = Histogram.compare [('a', 1)] [('a', 2)] = -1

let%test "Histogram.compare" =
  Histogram.compare [('a', 1)] [('a', 1); ('b', 1)] = -1

let%test "Histogram.compare" =
  Histogram.compare [('a', 1); ('b', 1)] [('a', 1); ('b', 1)] = 0

let%test "Histogram.compare" =
  Histogram.compare [('a', 1); ('b', 1)] [('a', 1); ('b', 2)] = -1

let%test "Histogram.compare" =
  Histogram.compare [('a', 1); ('b', 1)] [('a', 1)] = 1

let%test "Histogram.compare" = Histogram.compare [] [('a', 1)] = -1

let%test "Histogram.compare" = Histogram.compare [('a', 1)] [] = 1

let%test "are_anagrams" = Tp0.are_anagrams "tri" "rit"

let%test "are_anagrams" = not (Tp0.are_anagrams "tri" "riz")

let%test "find_anagrams" =
  Tp0.find_anagrams ["riz"; "rit"; "tri"; "tir"; "ateliers"; "lesterai"]
  = [["lesterai"; "ateliers"]; ["tir"; "tri"; "rit"]]
