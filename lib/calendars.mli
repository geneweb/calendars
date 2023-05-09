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
type moon_phase = NewMoon | FirstQuarter | FullMoon | LastQuarter

val make :
  'a kind ->
  day:int ->
  month:int ->
  year:int ->
  delta:sdn ->
  ('a date, string) result

val of_sdn : 'a kind -> sdn -> ('a date, string) result
val to_sdn : 'a date -> sdn
val to_gregorian : 'a date -> gregorian date
val to_julian : 'a date -> julian date
val to_french : 'a date -> french date
val to_hebrew : 'a date -> hebrew date
val moon_phase_of_sdn : sdn -> (moon_phase * int * int) option * int
val sdn_hebrew_anno_mundi : sdn
