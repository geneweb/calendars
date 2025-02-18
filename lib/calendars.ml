(* Borrowed from Scott E. Lee http://genealogy.org/~scottlee/;
   converted his C program into this OCaml program.
   SDN 1 is November 25, 4714 BC Gregorian calendar *)
(* Changed gregorian and julian to work always with negative years
   (Scott's version worked only for years > -4800 *)

type gregorian
type julian
type french
type hebrew

type _ kind =
  | Gregorian : gregorian kind
  | Julian : julian kind
  | French : french kind
  | Hebrew : hebrew kind

let kind_to_string : type a. a kind -> string =
 fun kind ->
  match kind with
  | Gregorian -> "Gregorian"
  | Julian -> "Julian"
  | French -> "French"
  | Hebrew -> "Hebrew"

module Unsafe = struct
  type 'a date = {
    day : int;
    month : int;
    year : int;
    delta : int;
    kind : 'a kind;
  }

  let to_string { day; month; year; delta; kind } =
    Printf.sprintf "{day = %d; month = %d; year = %d; delta = %d; kind = %s" day
      month year delta (kind_to_string kind)
end

type 'a date = 'a Unsafe.date = {
  day : int;
  month : int;
  year : int;
  delta : int;
  kind : 'a kind;
}

type sdn = int

let mydiv x y = if x >= 0 then x / y else (x - y + 1) / y
let mymod x y = if x >= 0 then x mod y else ((x + 1) mod y) + y - 1

(* gregorian *)

let sdn_offset = 1721119
let days_per_5_months = 153
let days_per_4_years = 1461
let days_per_400_years = 146097

let sdn_of_gregorian d =
  let year = if d.year < 0 then d.year + 1 else d.year in
  let month, year =
    if d.month > 2 then (d.month - 3, year) else (d.month + 9, year - 1)
  in
  mydiv (mydiv year 100 * days_per_400_years) 4
  + mydiv (mymod year 100 * days_per_4_years) 4
  + (((month * days_per_5_months) + 2) / 5)
  + d.day + sdn_offset

let gregorian_of_sdn sdn =
  let temp = ((sdn - sdn_offset) * 4) - 1 in
  let century = mydiv temp days_per_400_years in
  let temp = (mydiv (mymod temp days_per_400_years) 4 * 4) + 3 in
  let year = (century * 100) + mydiv temp days_per_4_years in
  let dayOfYear = mydiv (mymod temp days_per_4_years) 4 + 1 in
  let temp = (dayOfYear * 5) - 3 in
  let month = mydiv temp days_per_5_months in
  let day = mydiv (mymod temp days_per_5_months) 5 + 1 in
  let month, year =
    if month < 10 then (month + 3, year) else (month - 9, year + 1)
  in
  let year = if year <= 0 then year - 1 else year in
  { day; month; year; delta = 0; kind = Gregorian }

(* julian *)

let sdn_offset = 1721117
let days_per_5_months = 153
let days_per_4_years = 1461

let sdn_of_julian d =
  let year = if d.year < 0 then d.year + 1 else d.year in
  let month, year =
    if d.month > 2 then (d.month - 3, year) else (d.month + 9, year - 1)
  in
  mydiv (year * days_per_4_years) 4
  + (((month * days_per_5_months) + 2) / 5)
  + d.day + sdn_offset

let julian_of_sdn sdn =
  let temp = ((sdn - sdn_offset) * 4) - 1 in
  let year = mydiv temp days_per_4_years in
  let dayOfYear = mydiv (mymod temp days_per_4_years) 4 + 1 in
  let temp = (dayOfYear * 5) - 3 in
  let month = mydiv temp days_per_5_months in
  let day = mydiv (mymod temp days_per_5_months) 5 + 1 in
  let month, year =
    if month < 10 then (month + 3, year) else (month - 9, year + 1)
  in
  let year = if year <= 0 then year - 1 else year in
  { day; month; year; delta = 0; kind = Julian }

(* french revolution *)
(* this code comes from Remy Pialat; thanks to him *)

let modulo pAngle pVal =
  let x = truncate (pAngle /. pVal) in
  let y = float x *. pVal in
  pAngle -. y

let degVersRad pAngle =
  let a = modulo pAngle 360.0 in
  a *. 3.141592653589793 /. 180.0

let sinDeg pAngle = sin (degVersRad pAngle)

let modulo360 pAngle =
  let angle = modulo pAngle 360.0 in
  if angle < 0.0 then angle +. 360.0 else angle

let equinoxeAutomne pAnnee =
  let pAnnee = if pAnnee < 0 then pAnnee + 1 else pAnnee in
  let f = 12.0 in
  let q = 30.0 in
  let i = 0 in
  let k = 6.0 in
  let jd = ((float pAnnee +. (k /. f)) *. 365.2422) +. 1721141.3 in
  let rec loop i jd jdn =
    if abs_float (jd -. jdn) > 1.0E-12 && i + 1 < 20 then
      let i = i + 1 in
      let jdn = jd in
      let t = (jd -. 2415020.0) /. 36525.0 in
      let t2 = t *. t in
      let t3 = t2 *. t in
      let l = 279.69688 +. (36000.76892 *. t) +. (3.025E-4 *. t2) in
      let m =
        358.47583 +. (35999.04975 *. t) -. (1.5E-4 *. t2) -. (3.3E-6 *. t3)
      in
      let ll =
        l
        +. ((1.91946 -. (0.004789 *. t) -. (1.4E-5 *. t2)) *. sinDeg m)
        +. ((0.020094 -. (1.0E-4 *. t)) *. sinDeg (2.0 *. m))
        +. (0.00293 *. sinDeg (3.0 *. m))
      in
      let ll =
        ll -. 0.00569 -. (0.00479 *. sinDeg (259.18 -. (1934.142 *. t)))
      in
      let ll = modulo360 ll in
      let ll = if ll > 350.0 then ll -. 360.0 else ll in
      let jd = jd +. (1.014 *. ((k *. q) -. ll)) in
      loop i jd jdn
    else
      let d = jd -. floor jd in
      let j = truncate jd in
      if d >= 0.5 then j + 1 else j
  in
  loop i jd (-1.0)

let french_of_sdn sdn =
  let greg_date = gregorian_of_sdn sdn in
  let fst_vend_sdn = equinoxeAutomne greg_date.year in
  let year, fst_vend_sdn =
    if sdn < fst_vend_sdn then
      let fst_vend_sdn = equinoxeAutomne (greg_date.year - 1) in
      let year = greg_date.year - 1792 in
      (year, fst_vend_sdn)
    else
      let year = greg_date.year - 1791 in
      (year, fst_vend_sdn)
  in
  let ndays = sdn - fst_vend_sdn in
  let month = (ndays / 30) + 1 in
  let day = (ndays mod 30) + 1 in
  { day; month; year; delta = 0; kind = French }

let sdn_of_french d =
  let greg_year = d.year + 1791 in
  equinoxeAutomne greg_year + ((d.month - 1) * 30) + d.day - 1

(* hebrew *)

let halakim_per_hour = 1080
let halakim_per_day = 25920
let halakim_per_lunar_cycle = (29 * halakim_per_day) + 13753
let halakim_per_metonic_cycle = halakim_per_lunar_cycle * ((12 * 19) + 7)
let sdn_offset = 347997
let new_moon_of_creation = 31524
let sunday = 0
let monday = 1
let tuesday = 2
let wednesday = 3

(* let thursday = 4 *)
let friday = 5
(* let saturday = 6 *)

let noon = 18 * halakim_per_hour
let am3_11_20 = (9 * halakim_per_hour) + 204
let am9_32_43 = (15 * halakim_per_hour) + 589

let monthsPerYear =
  [|
    12; 12; 13; 12; 12; 13; 12; 13; 12; 12; 13; 12; 12; 13; 12; 12; 13; 12; 13;
  |]

let yearOffset =
  [|
    0;
    12;
    24;
    37;
    49;
    61;
    74;
    86;
    99;
    111;
    123;
    136;
    148;
    160;
    173;
    185;
    197;
    210;
    222;
  |]

let fTishri1 metonicYear moladDay moladHalakim =
  let tishri1 = moladDay in
  let dow = tishri1 mod 7 in
  let leapYear =
    match metonicYear with 2 | 5 | 7 | 10 | 13 | 16 | 18 -> true | _ -> false
  in
  let lastWasLeapYear =
    match metonicYear with 3 | 6 | 8 | 11 | 14 | 17 | 0 -> true | _ -> false
  in
  let tishri1, dow =
    if
      moladHalakim >= noon
      || ((not leapYear) && dow = tuesday && moladHalakim >= am3_11_20)
      || (lastWasLeapYear && dow = monday && moladHalakim >= am9_32_43)
    then
      let tishri1 = tishri1 + 1 in
      let dow = dow + 1 in
      let dow = if dow = 7 then 0 else dow in
      (tishri1, dow)
    else (tishri1, dow)
  in
  if dow = wednesday || dow = friday || dow = sunday then tishri1 + 1
  else tishri1

let moladOfMetonicCycle metonicCycle =
  let r1 = new_moon_of_creation in
  let r1 = r1 + (metonicCycle * (halakim_per_metonic_cycle land 0xFFFF)) in
  let r2 = r1 lsr 16 in
  let r2 =
    r2 + (metonicCycle * ((halakim_per_metonic_cycle lsr 16) land 0xFFFF))
  in
  let d2 = r2 / halakim_per_day in
  let r2 = r2 - (d2 * halakim_per_day) in
  let r1 = (4. *. float (r2 lsl 14)) +. float (r1 land 0xFFFF) in
  let d1 = truncate ((r1 /. float halakim_per_day) +. 0.5) in
  let r1 = truncate (r1 -. (float d1 *. float halakim_per_day) +. 0.5) in
  let pMoladDay = (d2 lsl 16) lor d1 in
  let pMoladHalakim = r1 in
  (pMoladDay, pMoladHalakim)

let findStartOfYear year =
  let pMetonicCycle = (year - 1) / 19 in
  (* On prend la valeur absolue parce que (0 - 1) mod 19 = -1    *)
  (* et après, on fait un 'index out of bounds' dans yearOffset. *)
  let pMetonicYear = abs ((year - 1) mod 19) in
  let pMoladDay, pMoladHalakim = moladOfMetonicCycle pMetonicCycle in
  let pMoladHalakim =
    pMoladHalakim + (halakim_per_lunar_cycle * yearOffset.(pMetonicYear))
  in
  let pMoladDay = pMoladDay + (pMoladHalakim / halakim_per_day) in
  let pMoladHalakim = pMoladHalakim mod halakim_per_day in
  let pTishri1 = fTishri1 pMetonicYear pMoladDay pMoladHalakim in
  (pMetonicCycle, pMetonicYear, pMoladDay, pMoladHalakim, pTishri1)

let sdn_of_hebrew d =
  (* correction possible ? *)
  (* let d = { (d) with year = if d.year <= 0 then 1 else d.year } in *)
  let sdn =
    match d.month with
    | 1 | 2 ->
        let _metonicCycle, _metonicYear, _moladDay, _moladHalakim, tishri1 =
          findStartOfYear d.year
        in
        if d.month = 1 then tishri1 + d.day - 1 else tishri1 + d.day + 29
    | 3 ->
        let _metonicCycle, metonicYear, moladDay, moladHalakim, tishri1 =
          findStartOfYear d.year
        in
        let moladHalakim =
          moladHalakim + (halakim_per_lunar_cycle * monthsPerYear.(metonicYear))
        in
        let moladDay = moladDay + (moladHalakim / halakim_per_day) in
        let moladHalakim = moladHalakim mod halakim_per_day in
        let tishri1After =
          fTishri1 ((metonicYear + 1) mod 19) moladDay moladHalakim
        in
        let yearLength = tishri1After - tishri1 in
        if yearLength = 355 || yearLength = 385 then tishri1 + d.day + 59
        else tishri1 + d.day + 58
    | 4 | 5 | 6 ->
        let _metonicCycle, _metonicYear, _moladDay, _moladHalakim, tishri1After
            =
          findStartOfYear (d.year + 1)
        in
        (* On prend la valeur absolue parce que (0 - 1) mod 19 = -1    *)
        (* et après, on fait un 'index out of bounds' dans yearOffset. *)
        let lengthOfAdarIAndII =
          if monthsPerYear.(abs ((d.year - 1) mod 19)) = 12 then 29 else 59
        in
        if d.month = 4 then tishri1After + d.day - lengthOfAdarIAndII - 237
        else if d.month = 5 then tishri1After + d.day - lengthOfAdarIAndII - 208
        else tishri1After + d.day - lengthOfAdarIAndII - 178
    | _ -> (
        let _metonicCycle, _metonicYear, _moladDay, _moladHalakim, tishri1After
            =
          findStartOfYear (d.year + 1)
        in
        match d.month with
        | 7 -> tishri1After + d.day - 207
        | 8 -> tishri1After + d.day - 178
        | 9 -> tishri1After + d.day - 148
        | 10 -> tishri1After + d.day - 119
        | 11 -> tishri1After + d.day - 89
        | 12 -> tishri1After + d.day - 60
        | 13 -> tishri1After + d.day - 30
        | _ -> invalid_arg "sdn_of_hebrew")
  in
  sdn + sdn_offset

let findTishriMolad inputDay =
  let metonicCycle = (inputDay + 310) / 6940 in
  let moladDay, moladHalakim = moladOfMetonicCycle metonicCycle in
  let moladDay, moladHalakim, metonicCycle =
    let rec loop moladDay moladHalakim metonicCycle =
      if moladDay < inputDay - 6940 + 310 then
        let metonicCycle = metonicCycle + 1 in
        let moladHalakim = moladHalakim + halakim_per_metonic_cycle in
        let moladDay = moladDay + (moladHalakim / halakim_per_day) in
        let moladHalakim = moladHalakim mod halakim_per_day in
        loop moladDay moladHalakim metonicCycle
      else (moladDay, moladHalakim, metonicCycle)
    in
    loop moladDay moladHalakim metonicCycle
  in
  let metonicYear, moladDay, moladHalakim =
    let rec loop metonicYear moladDay moladHalakim =
      if metonicYear < 18 then
        if moladDay > inputDay - 74 then (metonicYear, moladDay, moladHalakim)
        else
          let moladHalakim =
            moladHalakim
            + (halakim_per_lunar_cycle * monthsPerYear.(metonicYear))
          in
          let moladDay = moladDay + (moladHalakim / halakim_per_day) in
          let moladHalakim = moladHalakim mod halakim_per_day in
          loop (metonicYear + 1) moladDay moladHalakim
      else (metonicYear, moladDay, moladHalakim)
    in
    loop 0 moladDay moladHalakim
  in
  (metonicCycle, metonicYear, moladDay, moladHalakim)

let glop inputDay tishri1 tishri1After =
  let yearLength = tishri1After - tishri1 in
  let day = inputDay - tishri1 - 29 in
  if yearLength = 355 || yearLength = 385 then
    if day <= 30 then (2, day) else (3, day - 30)
  else if day <= 29 then (2, day)
  else (3, day - 29)

let hebrew_of_sdn sdn =
  let inputDay = sdn - sdn_offset in
  let year, month, day =
    if inputDay <= 0 then (0, 0, 0)
    else
      let metonicCycle, metonicYear, day, halakim = findTishriMolad inputDay in
      let init_day = day in
      let tishri1 = fTishri1 metonicYear day halakim in
      if inputDay >= tishri1 then
        let year = (metonicCycle * 19) + metonicYear + 1 in
        if inputDay < tishri1 + 59 then
          if inputDay < tishri1 + 30 then (year, 1, inputDay - tishri1 + 1)
          else (year, 2, inputDay - tishri1 - 29)
        else
          let halakim =
            halakim + (halakim_per_lunar_cycle * monthsPerYear.(metonicYear))
          in
          let day = day + (halakim / halakim_per_day) in
          let halakim = halakim mod halakim_per_day in
          let tishri1After = fTishri1 ((metonicYear + 1) mod 19) day halakim in
          let month, day = glop inputDay tishri1 tishri1After in
          (year, month, day)
      else
        let year = (metonicCycle * 19) + metonicYear in
        if inputDay >= tishri1 - 177 then
          let month, day =
            if inputDay > tishri1 - 30 then (13, inputDay - tishri1 + 30)
            else if inputDay > tishri1 - 60 then (12, inputDay - tishri1 + 60)
            else if inputDay > tishri1 - 89 then (11, inputDay - tishri1 + 89)
            else if inputDay > tishri1 - 119 then (10, inputDay - tishri1 + 119)
            else if inputDay > tishri1 - 148 then (9, inputDay - tishri1 + 148)
            else (8, inputDay - tishri1 + 178)
          in
          (year, month, day)
        else if monthsPerYear.((year - 1) mod 19) = 13 then
          let month = 7 in
          let day = inputDay - tishri1 + 207 in
          if day > 0 then (year, month, day)
          else
            let month = month - 1 in
            let day = day + 30 in
            if day > 0 then (year, month, day)
            else
              let month = month - 1 in
              let day = day + 30 in
              if day > 0 then (year, month, day)
              else
                let month = month - 1 in
                let day = day + 29 in
                if day > 0 then (year, month, day)
                else
                  let tishri1After = tishri1 in
                  let _metonicCycle, metonicYear, day, halakim =
                    findTishriMolad (init_day - 365)
                  in
                  let tishri1 = fTishri1 metonicYear day halakim in
                  let month, day = glop inputDay tishri1 tishri1After in
                  (year, month, day)
        else
          let month = 6 in
          let day = inputDay - tishri1 + 207 in
          if day > 0 then (year, month, day)
          else
            let month = month - 1 in
            let day = day + 30 in
            if day > 0 then (year, month, day)
            else
              let month = month - 1 in
              let day = day + 29 in
              if day > 0 then (year, month, day)
              else
                let tishri1After = tishri1 in
                let _metonicCycle, metonicYear, day, halakim =
                  findTishriMolad (init_day - 365)
                in
                let tishri1 = fTishri1 metonicYear day halakim in
                let month, day = glop inputDay tishri1 tishri1After in
                (year, month, day)
  in
  { day; month; year; delta = 0; kind = Hebrew }

type erroneous_date_kind = Invalid_day | Invalid_month | Invalid_year
type 'a erroneous_date = { kind : erroneous_date_kind; value : 'a Unsafe.date }

let make :
    type a.
    a kind ->
    day:int ->
    month:int ->
    year:int ->
    delta:int ->
    (a date, a erroneous_date) result =
 fun kind ~day ~month ~year ~delta ->
  let gregorian_nb_days_upper_bound =
    [| 31; 29; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31 |]
  in
  let hebrew_nb_days_upper_bound =
    (* last two are for Adar I and II;
       Adar II should be 29, but we keep it simple and do not check for leap years *)
    [| 30; 29; 30; 29; 30; 29; 30; 30; 30; 29; 30; 30; 30 |]
  in
  (* A year zero does not exist in the Anno Domini (AD) calendar year
     system commonly used to number years in the Gregorian
     and Julian calendar. *)
  let check_day, check_month, check_year =
    let check ~error_kind is_ok =
      if is_ok () then Ok ()
      else
        Error { kind = error_kind; value = { day; month; year; delta; kind } }
    in
    ( check ~error_kind:Invalid_day,
      check ~error_kind:Invalid_month,
      check ~error_kind:Invalid_year )
  in
  let ( >>= ) = Result.bind in
  let check_greg () =
    check_year (fun () -> year <> 0) >>= fun () ->
    check_month (fun () -> month <= 12) >>= fun () ->
    check_day (fun () -> day <= gregorian_nb_days_upper_bound.(month - 1))
  in
  let valid =
    check_day (fun () -> day > 0) >>= fun () ->
    check_month (fun () -> month > 0) >>= fun () ->
    match kind with
    | Gregorian -> check_greg ()
    | Julian ->
        (* Julian calendar was different before 45 BC *)
        Result.fold ~ok:Result.ok
          ~error:(Fun.const @@ check_greg ())
          (check_year (fun () -> year < -45))
    | Hebrew ->
        check_month (fun () -> month <= 13) >>= fun () ->
        check_day (fun () -> day <= hebrew_nb_days_upper_bound.(month - 1))
    | French ->
        check_month (fun () -> month <= 13) >>= fun () ->
        check_day (fun () -> day <= 30)
  in
  Result.map (fun () -> { day; month; year; delta; kind }) valid

let to_sdn : type a. a date -> sdn =
 fun date ->
  match date.kind with
  | Gregorian -> sdn_of_gregorian date
  | Julian -> sdn_of_julian date
  | French -> sdn_of_french date
  | Hebrew -> sdn_of_hebrew date

let to_gregorian : type a. a date -> gregorian date =
 fun date ->
  match date.kind with
  | Gregorian -> date
  | Julian | French | Hebrew -> to_sdn date |> gregorian_of_sdn

let to_julian : type a. a date -> julian date =
 fun date ->
  match date.kind with
  | Julian -> date
  | Gregorian | French | Hebrew -> to_sdn date |> julian_of_sdn

let to_french : type a. a date -> french date =
 fun date ->
  match date.kind with
  | French -> date
  | Gregorian | Julian | Hebrew -> to_sdn date |> french_of_sdn

let to_hebrew : type a. a date -> hebrew date =
 fun date ->
  match date.kind with
  | Hebrew -> date
  | Gregorian | Julian | French -> to_sdn date |> hebrew_of_sdn

(* Moon phases *)
(* Borrowed from G.Satre of CNRS's program found at:
   http://portail.imcce.fr/fr/ephemerides/astronomie/Promenade/pages4/441.html
   Program written in JavaScript; converted into OCaml with code cleaning
   and transforming for interface sdn -> moon-day: but I did not understand
   everything and the code could perhaps be improved *)

type ('a, 'b) found = Found of 'a | NotYetFound of 'b
type moon_phase = NewMoon | FirstQuarter | FullMoon | LastQuarter

let jjdate date_JJD =
  let z1 = date_JJD +. 0.5 in
  let z = truncate z1 in
  let a =
    if z < 2299161 then float z
    else
      let alpha = truncate ((float z -. 1867216.25) /. 36524.25) in
      float z +. 1. +. float alpha -. float (truncate (float alpha /. 4.0))
  in
  let b = a +. 1524.0 in
  let c = float (truncate ((b -. 122.1) /. 365.25)) in
  let d = float (truncate (365.25 *. c)) in
  let e = float (truncate ((b -. d) /. 30.6001)) in
  let day = truncate (b -. d -. float (truncate (30.6001 *. e))) in
  let month = if e < 13.5 then truncate (e -. 1.0) else truncate (e -. 13.0) in
  let year =
    if month >= 3 then truncate (c -. 4716.0) else truncate (c -. 4715.0)
  in
  (day, month, year)

let is_leap_year year =
  if year mod 4 = 0 then
    if year mod 100 = 0 && year mod 400 != 0 then false else true
  else false

let init_moon_age month day leap_year =
  let nbdays =
    if month = 2 then if not leap_year then 28 else 29
    else if month < 8 then if month land 1 != 0 then 31 else 30
    else if month land 1 != 0 then 30
    else 31
  in
  nbdays - day + 2

let testmon i date first_moon_age_found date_JJD month_day moon_age =
  let d = float date.year /. 100.0 in
  let tetus = (32.23 *. (d -. 18.30) *. (d -. 18.30)) -. 15.0 in
  let tetuj = tetus /. 86400.0 in
  let date_JJD = date_JJD +. 0.0003472222 -. tetuj in
  let day, month, year = jjdate date_JJD in
  let leap_year = is_leap_year year in
  let inside_month = month = date.month in
  let month_day, moon_age =
    if
      i = 0
      && (date.month > month || (month = 12 && date.month = 1))
      && not first_moon_age_found
    then (1, init_moon_age month day leap_year)
    else (month_day, moon_age)
  in
  (inside_month, date_JJD, leap_year, month_day, moon_age)

let affmoph i date_JJD leap_year first_moon_age_found month_day moon_age date =
  let tabjm = [| 31; 28; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31 |] in
  let day, month, year = jjdate date_JJD in
  let fracj = mod_float (date_JJD +. 0.5) 1.0 in
  let hh = fracj *. 24.0 in
  let hh = int_of_float (floor hh +. 0.1) in
  let fracj = fracj -. (float hh /. 24.0) in
  let mm = fracj *. 1440.0 in
  let mm = int_of_float (floor mm +. 0.1) in
  let hh =
    if hh = 24 then
      let jfin = tabjm.(month - 1) in
      let _ = assert (leap_year = is_leap_year year) in
      let jfin = if month = 2 && leap_year then 29 else jfin in
      if day < jfin then 0 else hh
    else hh
  in
  let rec loop month_day moon_age =
    if month_day < day then
      if month_day = date.day then Found (None, moon_age)
      else loop (month_day + 1) (moon_age + 1)
    else if month_day = date.day then
      let r =
        match i with
        | 0 -> (Some (NewMoon, hh, mm), 1)
        | 1 -> (Some (FirstQuarter, hh, mm), moon_age)
        | 2 -> (Some (FullMoon, hh, mm), moon_age)
        | _ -> (Some (LastQuarter, hh, mm), moon_age)
      in
      Found r
    else
      let moon_age, first_moon_age_found =
        if i = 0 then (2, true) else (moon_age + 1, first_moon_age_found)
      in
      NotYetFound (first_moon_age_found, month_day + 1, moon_age)
  in
  loop month_day moon_age

let moon_phase_of_gregorian date =
  let pi314 = 3.141592653589793 in
  let tabm =
    [|
      0.041;
      0.126;
      0.203;
      0.288;
      0.370;
      0.455;
      0.537;
      0.622;
      0.707;
      0.789;
      0.874;
      0.956;
    |]
  in
  let year, date_month =
    if date.month = 1 then (date.year - 1, 12) else (date.year, date.month - 1)
  in
  let year = float year +. tabm.(date_month - 1) in
  let ini_k =
    let k = (year -. 1900.0) *. 12.3685 in
    let k = float (truncate k) -. 0.25 in
    if k < 0.0 then k -. 1. else k
  in
  let rad = pi314 /. 180.0 in
  let rec loop ii prev_k leap_year first_moon_age_found month_day moon_age =
    if ii >= 12 then
      let nbdays =
        if date.month = 2 then if not leap_year then 28 else 29
        else if date.month < 8 then if date.month land 1 != 0 then 31 else 30
        else if date.month land 1 != 0 then 30
        else 31
      in
      let rec loop month_day moon_age =
        if month_day <= nbdays then
          if month_day = date.day then (None, moon_age)
          else loop (month_day + 1) (moon_age + 1)
        else failwith "moon_phase"
      in
      loop month_day moon_age
    else
      let k = prev_k +. 0.25 in
      let t = k /. 1236.85 in
      let t2 = t *. t in
      let t3 = t *. t2 in
      let j =
        2415020.75933 +. (29.5305888531 *. k) +. (0.0001337 *. t2)
        -. (0.000000150 *. t3)
        +. (0.00033 *. sin (rad *. (166.56 +. (132.87 *. t) -. (0.009 *. t2))))
      in
      let m =
        rad
        *. (359.2242 +. (29.10535608 *. k) -. (0.0000333 *. t2)
          -. (0.00000347 *. t3))
      in
      let m = mod_float m (2.0 *. pi314) in
      let mp =
        rad
        *. (306.0253 +. (385.81691806 *. k) +. (0.0107306 *. t2)
          +. (0.00001236 *. t3))
      in
      let mp = mod_float mp (2. *. pi314) in
      let f =
        rad
        *. (21.2964 +. (390.67050646 *. k) -. (0.0016528 *. t2)
          -. (0.00000239 *. t3))
      in
      let f = mod_float f (2. *. pi314) in
      let i = ii mod 4 in
      let date_JJD =
        if i = 0 || i = 2 then
          j
          +. ((0.1734 -. (0.000393 *. t)) *. sin m)
          +. (0.0021 *. sin (2.0 *. m))
          -. (0.4068 *. sin mp)
          +. (0.0161 *. sin (2.0 *. mp))
          -. (0.0004 *. sin (3.0 *. mp))
          +. (0.0104 *. sin (2.0 *. f))
          -. (0.0051 *. sin (m +. mp))
          -. (0.0074 *. sin (m -. mp))
          +. (0.0004 *. sin ((2.0 *. f) +. m))
          -. (0.0004 *. sin ((2.0 *. f) -. m))
          -. (0.0006 *. sin ((2.0 *. f) +. mp))
          +. (0.001 *. sin ((2.0 *. f) -. mp))
          +. (0.0005 *. sin (m +. (2.0 *. mp)))
        else
          let j =
            j
            +. ((0.1721 -. (0.0004 *. t)) *. sin m)
            +. (0.0021 *. sin (2.0 *. m))
            -. (0.6280 *. sin mp)
            +. (0.0089 *. sin (2.0 *. mp))
            -. (0.0004 *. sin (3.0 *. mp))
            +. (0.0079 *. sin (2.0 *. f))
            -. (0.0119 *. sin (m +. mp))
            -. (0.0047 *. sin (m -. mp))
            +. (0.0003 *. sin ((2.0 *. f) +. m))
            -. (0.0004 *. sin ((2.0 *. f) -. m))
            -. (0.0006 *. sin ((2.0 *. f) +. mp))
            +. (0.0021 *. sin ((2.0 *. f) -. mp))
            +. (0.0003 *. sin (m +. (2.0 *. mp)))
            +. (0.0004 *. sin (m -. (2.0 *. mp)))
            -. (0.0003 *. sin ((2.0 *. m) +. mp))
          in
          if i = 1 then j +. 0.0028 -. (0.0004 *. cos m) +. (0.0003 *. cos mp)
          else j -. 0.0028 +. (0.0004 *. cos m) -. (0.0003 *. cos mp)
      in
      let inside_month, date_JJD, leap_year, month_day, moon_age =
        testmon i date first_moon_age_found date_JJD month_day moon_age
      in
      if inside_month then
        match
          affmoph i date_JJD leap_year first_moon_age_found month_day moon_age
            date
        with
        | NotYetFound (first_moon_age_found, month_day, moon_age) ->
            loop (ii + 1) k leap_year first_moon_age_found month_day moon_age
        | Found x -> x
      else loop (ii + 1) k leap_year first_moon_age_found month_day moon_age
  in
  loop 0 ini_k false false 0 0

let moon_phase_of_sdn jd =
  let date = gregorian_of_sdn jd in
  if date.year < -4000 || date.year > 2500 then failwith "moon_phase_of_sdn"
  else moon_phase_of_gregorian date
