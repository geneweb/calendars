type gregorian
type julian
type french
type hebrew
type islamic

type _ kind =
  | Gregorian : gregorian kind
  | Julian : julian kind
  | French : french kind
  | Hebrew : hebrew kind
  | Islamic : islamic kind

module Unsafe : sig
  type 'a date = private {
    day : int;
    month : int;
    year : int;
    delta : int;
    kind : 'a kind;
  }

  val to_string : 'a date -> string
end

type 'a date = 'a Unsafe.date = private {
  day : int;
  month : int;
  year : int;
  delta : int;
  kind : 'a kind;
}

type sdn = int
type erroneous_date_kind = Invalid_day | Invalid_month | Invalid_year
type 'a erroneous_date = { kind : erroneous_date_kind; value : 'a Unsafe.date }

val make :
  'a kind ->
  day:int ->
  month:int ->
  year:int ->
  delta:sdn ->
  ('a date, 'a erroneous_date) result

val gregorian_of_sdn : sdn -> gregorian date
val julian_of_sdn : sdn -> julian date
val french_of_sdn : sdn -> french date
val hebrew_of_sdn : sdn -> hebrew date
val islamic_of_sdn : sdn -> islamic date
val to_sdn : 'a date -> sdn
val to_gregorian : 'a date -> gregorian date
val to_julian : 'a date -> julian date
val to_french : 'a date -> french date
val to_hebrew : 'a date -> hebrew date
val to_islamic : 'a date -> islamic date

type moon_phase = NewMoon | FirstQuarter | FullMoon | LastQuarter

val moon_phase_of_sdn : sdn -> (moon_phase * int * int) option * int
