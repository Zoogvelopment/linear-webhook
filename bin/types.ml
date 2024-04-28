module Linear = struct
  type payload_action = Create | Update | Remove

  let payload_action_of_yojson = function
    | `String "create" -> Create
    | `String "update" -> Update
    | `String "remove" -> Remove
    | _ -> failwith "Invalid payload action received"

  type payload = {
    action : payload_action;
    kind : string; [@key "type"]
    createdAt : string;
    data : Yojson.Safe.t;
    url : string;
    updatedFrom : Yojson.Safe.t option;
    webhookTimestamp : int;
    webhookId : string;
  }
  [@@deriving yojson]
end
