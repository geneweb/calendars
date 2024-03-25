(lang dune 2.9)
(name calendars)
(version 1.0.0)

(generate_opam_files true)
(license GPL-2.0-only)
(authors "Daniel de Rauglaudre")
(maintainers "Elie Canonici-Merle <elie.canonicimerle@geneanet.org>" "Olivier Pierre <olivier.pierre@geneanet.org>")
(source (github geneweb/calendars))

(package
  (name calendars)
  (synopsis "Convert dates between gregorian/julian/french/hebrew calendars")
  (description "OCaml library to convert dates between gregorian/julian/french/hebrew calendars. Code is originally from Geneweb.")
  (tags (moon-phase gregorian julian hebrew french-republican calendar date))
  (depends
    (ocaml (>= 4.08))
    (ounit2 :with-test)
  ))
