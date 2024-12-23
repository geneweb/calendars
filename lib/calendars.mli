type gregorian
type julian
type french
type hebrew

type _ kind =
  | Gregorian : gregorian kind
  | Julian : julian kind
  | French : french kind
  | Hebrew : hebrew kind

type 'a date = private {
  day : int;
  month : int;
  year : int;
  delta : int;
  kind : 'a kind;
}

type sdn = int

val make :
  'a kind ->
  day:int ->
  month:int ->
  year:int ->
  delta:sdn ->
  ('a date, [ `Invalid_day | `Invalid_month | `Invalid_year ]) result

val to_string : 'a date -> string
val gregorian_of_sdn : sdn -> gregorian date
val julian_of_sdn : sdn -> julian date
val french_of_sdn : sdn -> french date
val hebrew_of_sdn : sdn -> hebrew date
val to_sdn : 'a date -> sdn
val to_gregorian : 'a date -> gregorian date
val to_julian : 'a date -> julian date
val to_french : 'a date -> french date
val to_hebrew : 'a date -> hebrew date

type moon_phase = NewMoon | FirstQuarter | FullMoon | LastQuarter

val moon_phase_of_sdn : sdn -> (moon_phase * int * int) option * int

module Unsafe : sig
  val make : 'a kind -> day:int -> month:int -> year:int -> delta:sdn -> 'a date
end
