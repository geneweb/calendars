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
val to_sdn : t -> sdn
val to_gregorian : t -> t
val to_julian : t -> t
val to_french : t -> t
val to_hebrew : t -> t

type moon_phase = NewMoon | FirstQuarter | FullMoon | LastQuarter

val moon_phase_of_sdn : sdn -> (moon_phase * int * int) option * int
