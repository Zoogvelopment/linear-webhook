(lang dune 3.15)

(name linear_webhook)

(generate_opam_files true)

(source
 (github zoogvelopment/linear-webhook))

(authors "Andrew Brower <bigspeedfpv@gmail.com>")

(maintainers "Andrew Brower <bigspeedfpv@gmail.com>")

(license MIT)

(package
 (name linear_webhook)
 (synopsis "Linear webhook relay")
 (description "Forwards Linear webhook events to Discord")
 (depends ocaml dune dream lwt_ppx)
 (tags
  (discord webhook linear)))
