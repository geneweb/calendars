let () =
  let make ~day ~month ~year kind =
    Result.fold ~ok:Fun.id
      ~error:(fun erroneous_date -> erroneous_date.Calendars.value)
      (Calendars.make ~day ~month ~year ~delta:0 kind)
  in
  Js_of_ocaml.Js.export "Calendars"
    begin
      object%js
        method makeGregorian day month year =
          make ~day ~month ~year Calendars.Gregorian

        method makeJulian day month year =
          make ~day ~month ~year Calendars.Julian

        method makeFrench day month year =
          make ~day ~month ~year Calendars.French

        method makeHebrew day month year =
          make ~day ~month ~year Calendars.Hebrew

        method makeIslamic day month year =
          make ~day ~month ~year Calendars.Islamic

        method day { Calendars.day; _ } = day
        method month { Calendars.month; _ } = month
        method year { Calendars.year; _ } = year
        method delta { Calendars.delta; _ } = delta
        method gregorianOfSdn = Calendars.gregorian_of_sdn
        method julianOfSdn = Calendars.julian_of_sdn
        method frenchOfSdn = Calendars.french_of_sdn
        method hebrewOfSdn = Calendars.hebrew_of_sdn
        method islamicOfSdn = Calendars.islamic_of_sdn
        method toSdn = Calendars.to_sdn

        method moonPhaseOfSdn s =
          match Calendars.moon_phase_of_sdn s with
          | None, moon_age ->
              Js_of_ocaml.Js.Unsafe.obj
                [|
                  ("phase", Js_of_ocaml.Js.Unsafe.inject Js_of_ocaml.Js.null);
                  ("age", Js_of_ocaml.Js.Unsafe.inject moon_age);
                |]
          | Some (mp, hh, mm), moon_age ->
              let mp =
                match mp with
                | NewMoon -> Js_of_ocaml.Js.string "NewMoon"
                | FirstQuarter -> Js_of_ocaml.Js.string "FirstQuarter"
                | FullMoon -> Js_of_ocaml.Js.string "FullMoon"
                | LastQuarter -> Js_of_ocaml.Js.string "LastQuarter"
              in
              Js_of_ocaml.Js.Unsafe.obj
                [|
                  ("phase", Js_of_ocaml.Js.Unsafe.inject mp);
                  ("hour", Js_of_ocaml.Js.Unsafe.inject hh);
                  ("minute", Js_of_ocaml.Js.Unsafe.inject mm);
                  ("age", Js_of_ocaml.Js.Unsafe.inject moon_age);
                |]
      end
    end
