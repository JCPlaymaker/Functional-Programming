val explode : string -> char list

module Histogram : sig
  type t = (char * int) list

  val add : t -> char -> t

  val of_string : string -> t

  val compare : t -> t -> int
end

module HistogramMap : Map.S with type key = Histogram.t

val are_anagrams : string -> string -> bool

val find_anagrams : string list -> string list list
