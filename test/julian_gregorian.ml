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
            | Error s -> failwith s
          in
          let sdn' = to_sdn d in
          assert_equal_sdn !sdn sdn';
          assert_equal_dmy d (of_sdn sdn');
          incr sdn
        done
      done
  done

let _ =
  run_test_tt_main
    ("test suite for Calendars"
    >::: [
           test Julian julian_of_sdn julian_feb_len 0;
           test Gregorian gregorian_of_sdn gregorian_feb_len 38;
         ])
