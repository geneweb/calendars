open Js_of_ocaml
open Calendars

let _ =

  Js.export "Calendars" begin object%js

    method make day month year = { day ; month ; year ; delta = 0 }
    method day { day ; _ } = day
    method month { month ; _ } = month
    method year { year : _ } = year
    method delta { delta : _ } = delta

    method gregorianOfSdn = gregorian_of_sdn
    method julianOfSdn = julian_of_sdn
    method frenchOfSdn = french_of_sdn
    method hebrewOfSdn = hebrew_of_sdn

    method sdnOfGregorian = sdn_of_gregorian
    method sdnOfJulian = sdn_of_julian
    method sdnOfFrench = sdn_of_french
    method sdnOfHebrew = sdn_of_hebrew

    method gregorianOfJulian = gregorian_of_julian
    method julianOfGregorian = julian_of_gregorian
    method gregorianOfFrench = gregorian_of_french
    method frenchOfGregorian = french_of_gregorian
    method gregorianOfHebrew = gregorian_of_hebrew
    method hebrewOfGregorian = hebrew_of_gregorian

    method moonPhaseOfSdn s =
      match moon_phase_of_sdn s with
      | None, moon_age ->
        Js.Unsafe.obj [| "phase", Js.Unsafe.inject Js.null
                       ; "age", Js.Unsafe.inject moon_age |]
      | Some (mp, hh, mm), moon_age ->
        let mp = match mp with
          | NewMoon -> Js.string "NewMoon"
          | FirstQuarter -> Js.string "FirstQuarter"
          | FullMoon -> Js.string "FullMoon"
          | LastQuarter -> Js.string "LastQuarter"
        in
        Js.Unsafe.obj
          [| "phase", Js.Unsafe.inject mp
           ; "hour", Js.Unsafe.inject hh
           ; "minute", Js.Unsafe.inject mm
           ; "age", Js.Unsafe.inject moon_age
          |]

  end end
