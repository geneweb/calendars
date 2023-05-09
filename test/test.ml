(* Original test is from Scott E. Lee
 * Copyright 1993-1995, Scott E. Lee, all rights reserved.
 * Permission granted to use, copy, modify, distribute and sell so long as
 * the above copyright and this permission statement are retained in all
 * copies.  THERE IS NO WARRANTY - USE AT YOUR OWN RISK.
 *
 * OCaml port is from Julien Sagot
 * Copyright 2019, Julien Sagot
 *)

open OUnit
open Calendars

(* gregorian and julian calendar differ by their leap year rules *)
let julian_feb_len year =
  if (if year < 0 then year + 1 else year) mod 4 = 0 then 29 else 28

let gregorian_feb_len year =
  let year = if year < 0 then year + 1 else year in
  if year mod 4 = 0 && (year mod 100 <> 0 || year mod 400 = 0) then 29 else 28

let month_len = [| 31; 28; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31 |]

let assert_equal_dmy =
  assert_equal ~printer:(fun { day; month; year; _ } ->
      Printf.sprintf "{ day:(%d) ; month:(%d) ; year:(%d) }" day month year)

let assert_equal_sdn = assert_equal ~printer:string_of_int

let kind_to_string : type a. a kind -> string =
 fun kind ->
  match kind with
  | Gregorian -> "Gregorian"
  | Julian -> "Julian"
  | French -> "French"
  | Hebrew -> "Hebrew"

let test : type a. a kind -> (int -> a date) -> (int -> int) -> int -> test =
 fun kind of_sdn feb_len sdn_offset ->
  Printf.sprintf "%s <-> SDN" (kind_to_string kind) >:: fun _ ->
  (* we start the loop on the first day of the Hebrew calendar
     in the Julian calendar (day=7; month= 7; year=-3761);
          but this does not correspond to the same SDN for Julian and Gregorian
          this is why we have a +30 offset for Gregorian calendar *)
  let buggy_hebrew_dates = ref 0 in
  let sdn = ref sdn_offset in
  let year_start = -3761 in
  for year = year_start to 10000 do
    (* year zero does not exists *)
    if year <> 0 then
      let month_start = if year = year_start then 10 else 1 in
      for month = month_start to 12 do
        let day_start =
          if year = year_start && month = month_start then 7 else 1
        in
        let stop = if month = 2 then feb_len year else month_len.(month - 1) in
        for day = day_start to stop do
          let d = Result.get_ok @@ make kind ~day ~month ~year ~delta:0 in
          let sdn' = to_sdn d in
          assert_equal_sdn !sdn sdn';
          assert_equal_dmy d (of_sdn sdn');
          assert_equal_sdn !sdn (to_gregorian d |> to_sdn);
          assert_equal_sdn !sdn (to_julian d |> to_sdn);
          assert_equal_sdn !sdn (to_french d |> to_sdn);
          (* TODO some date/sdn conversion are buggy in Hebrew;
             (never more than +/- 2 SDN) *)
          if !sdn <> (to_hebrew d |> to_sdn) then incr buggy_hebrew_dates;
          incr sdn
        done
      done
  done;
  Printf.eprintf "bad to_hebrew => to_sdn round trip: %d\n" !buggy_hebrew_dates

let _ =
  run_test_tt_main
    ("test suite for Calendars"
    >::: [
           (* It is probably irrelevant to test both Julian and Gregorian here... *)
           test Julian
             (fun sdn -> of_sdn Julian sdn |> Result.get_ok)
             julian_feb_len
             (sdn_hebrew_anno_mundi + 1);
           test Gregorian
             (fun sdn -> of_sdn Gregorian sdn |> Result.get_ok)
             gregorian_feb_len
             (sdn_hebrew_anno_mundi + 1 + 30);
         ])
