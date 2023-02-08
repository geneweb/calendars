type kind = Gregorian | Julian | French | Hebrew

type t = private {
  day : int;
  month : int;
  year : int;
  delta : int;
  kind : kind;
}

type sdn = int

val make : kind -> day:int -> month:int -> year:int -> delta:sdn -> t
val gregorian_of_sdn : sdn -> t
val julian_of_sdn : sdn -> t
val french_of_sdn : sdn -> t
val hebrew_of_sdn : sdn -> t

(* TODO to_sdn : t -> sdn *)
val sdn_of_gregorian : t -> sdn
val sdn_of_julian : t -> sdn
val sdn_of_french : t -> sdn
val sdn_of_hebrew : t -> sdn

(* TODO to_gregorian : t -> t ... *)
val gregorian_of_julian : t -> t
val julian_of_gregorian : t -> t
val gregorian_of_french : t -> t
val french_of_gregorian : t -> t
val gregorian_of_hebrew : t -> t
val hebrew_of_gregorian : t -> t

type moon_phase = NewMoon | FirstQuarter | FullMoon | LastQuarter

val moon_phase_of_sdn : sdn -> (moon_phase * int * int) option * int
