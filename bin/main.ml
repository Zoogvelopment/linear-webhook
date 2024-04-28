let linear_ips = [ "35.231.147.226"; "35.243.134.228" ]

let request_is_valid secret body req =
  let verify_signature ls =
    let open Digestif.SHA256 in
    let digest = body |> hmac_string ~key:secret |> to_hex in
    Dream.debug (fun m -> m "Body signature is %s" digest);
    digest = ls
  in
  let ip =
    match Dream.header req "X-Forwarded-For" with
    | Some ip -> ip
    | None -> Dream.client req
  in
  Dream.debug (fun m -> m "IP: %s" ip);
  match List.mem ip linear_ips with
  | false -> false
  | true -> (
      match Dream.header req "Linear-Signature" with
      | None -> false
      | Some linear_signature ->
          Dream.debug (fun m -> m "Linear signature is %s" linear_signature);
          verify_signature linear_signature)

let forward_webhook secret req =
  let%lwt body = Dream.body req in
  match request_is_valid secret body req with
  | false -> Dream.empty `Bad_Request
  | true ->
      let%lwt body = Dream.body req in
      Dream.debug (fun m -> m "%s" body);
      Dream.empty `OK

let () =
  Dotenv.export () |> ignore;
  let webhook_secret = "WEBHOOK_SECRET" |> Sys.getenv in
  Dream.initialize_log ~level:`Debug ();
  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/" (fun _ -> Dream.respond "OK");
         Dream.post "/" (forward_webhook webhook_secret);
       ]
