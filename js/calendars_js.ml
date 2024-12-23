let _ =

  Js_of_ocaml.Js.export "Calendars" begin object%js

    method make day month year = { Calendars.day ; month ; year ; delta = 0 }
    method day { Calendars.day ; _ } = day
    method month { Calendars.month ; _ } = month
    method year { Calendars.year : _ } = year
    method delta { Calendars.delta : _ } = delta

    method gregorianOfSdn = Calendars.gregorian_of_sdn
    method julianOfSdn = Calendars.julian_of_sdn
    method frenchOfSdn = Calendars.french_of_sdn
    method hebrewOfSdn = Calendars.hebrew_of_sdn

    method sdnOfGregorian = Calendars.sdn_of_gregorian
    method sdnOfJulian = Calendars.sdn_of_julian
    method sdnOfFrench = Calendars.sdn_of_french
    method sdnOfHebrew = Calendars.sdn_of_hebrew

    method gregorianOfJulian = Calendars.gregorian_of_julian
    method julianOfGregorian = Calendars.julian_of_gregorian
    method gregorianOfFrench = Calendars.gregorian_of_french
    method frenchOfGregorian = Calendars.french_of_gregorian
    method gregorianOfHebrew = Calendars.gregorian_of_hebrew
    method hebrewOfGregorian = Calendars.hebrew_of_gregorian

    method moonPhaseOfSdn s =
      match Calendars.moon_phase_of_sdn s with
      | None, moon_age ->
        Js_of_ocaml.Js.Unsafe.obj [| "phase", Js_of_ocaml.Js.Unsafe.inject Js_of_ocaml.Js.null
                       ; "age", Js_of_ocaml.Js.Unsafe.inject moon_age |]
      | Some (mp, hh, mm), moon_age ->
        let mp = match mp with
          | NewMoon -> Js_of_ocaml.Js.string "NewMoon"
          | FirstQuarter -> Js_of_ocaml.Js.string "FirstQuarter"
          | FullMoon -> Js_of_ocaml.Js.string "FullMoon"
          | LastQuarter -> Js_of_ocaml.Js.string "LastQuarter"
        in
        Js_of_ocaml.Js.Unsafe.obj
          [| "phase", Js_of_ocaml.Js.Unsafe.inject mp
           ; "hour", Js_of_ocaml.Js.Unsafe.inject hh
           ; "minute", Js_of_ocaml.Js.Unsafe.inject mm
           ; "age", Js_of_ocaml.Js.Unsafe.inject moon_age
          |]

  end end
