let linear_ips = [ "35.231.147.226"; "35.243.134.228" ]
let webhook_secret = "WEBHOOK_SECRET" |> Sys.getenv |> Cstruct.of_string

let request_is_valid body req =
  let verify_signature ls =
    let open Mirage_crypto.Hash.SHA256 in
    let digest =
      body |> Cstruct.of_string |> hmac ~key:webhook_secret
      |> Cstruct.to_hex_string
    in
    digest = ls
  in
  let ip = Dream.client req in
  match List.mem ip linear_ips with
  | false -> false
  | true -> (
      match Dream.header req "linear-signature" with
      | None -> false
      | Some linear_signature -> verify_signature linear_signature)

let forward_webhook req =
  let%lwt body = Dream.body req in
  match request_is_valid body req with
  | false -> Dream.empty `Bad_Request
  | true ->
      let%lwt body = Dream.body req in
      Dream.debug (fun m -> m "%s" body);
      Dream.empty `OK

let () =
  Dream.initialize_log ~level:`Debug ();
  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/" (fun _ -> Dream.respond "OK");
         Dream.post "/" forward_webhook;
       ]
