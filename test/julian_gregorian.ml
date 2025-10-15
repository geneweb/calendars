(* Original test is from Scott E. Lee
 * Copyright 1993-1995, Scott E. Lee, all rights reserved.
 * Permission granted to use, copy, modify, distribute and sell so long as
 * the above copyright and this permission statement are retained in all
 * copies.  THERE IS NO WARRANTY - USE AT YOUR OWN RISK.
 *
 * OCaml port is from Julien Sagot
 * Copyright 2019, Julien Sagot
 *)

open Calendars

(* gregorian and julian calendar differ by their leap year rules *)
let julian_feb_len year =
  if (if year < 0 then year + 1 else year) mod 4 = 0 then 29 else 28

let gregorian_feb_len year =
  let year = if year < 0 then year + 1 else year in
  if year mod 4 = 0 && (year mod 100 <> 0 || year mod 400 = 0) then 29 else 28

let month_len = [| 31; 28; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31 |]

let testable_dmy (_ : _ Calendars.kind) =
  Alcotest.testable
    (fun fmt { day; month; year; _ } ->
      Format.fprintf fmt "{ day:(%d) ; month:(%d) ; year:(%d) }" day month year)
    ( = )

let test :
    type a. a kind -> (int -> a date) -> (int -> int) -> int -> unit -> unit =
 fun kind of_sdn feb_len sdn_offset () ->
  (* we start the loop on 1 january -4713 (SDN=0); but this does not correspond to the same SDN
     for Julian and Gregorian this is why we have a +38 offset for Gregorian calendar *)
  let sdn = ref sdn_offset in
  for year = -4713 to 10000 do
    (* year zero does not exists *)
    if year <> 0 then
      for month = 1 to 12 do
        let stop = if month = 2 then feb_len year else month_len.(month - 1) in
        for day = 1 to stop do
          let d =
            match make kind ~day ~month ~year ~delta:0 with
            | Ok d -> d
            | Error { Calendars.kind; value } ->
                failwith
                  (Printf.sprintf "Invalid %s: '%s'"
                     (match kind with
                     | Calendars.Invalid_day -> "day"
                     | Calendars.Invalid_month -> "month"
                     | Calendars.Invalid_year -> "year")
                     (Calendars.Unsafe.to_string value))
          in
          let sdn' = to_sdn d in
          Alcotest.check Alcotest.int "" !sdn sdn';
          Alcotest.check (testable_dmy kind) "" d (of_sdn sdn');
          incr sdn
        done
      done
  done

let _ =
  Alcotest.run "test suite for Calendars"
    [
      ( "Julian <-> SDN",
        [
          Alcotest.test_case "julian_of_sdn" `Quick
            (test Julian julian_of_sdn julian_feb_len 0);
        ] );
      ( "Gregorian <-> SDN",
        [
          Alcotest.test_case "gregorian_of_sdn" `Quick
            (test Gregorian gregorian_of_sdn gregorian_feb_len 38);
        ] );
    ]
