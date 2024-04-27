let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [ Dream.get "/healthcheck" (fun _ -> Dream.respond "OK") ]
;;

