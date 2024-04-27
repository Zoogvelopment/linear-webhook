module Server = struct
  let start () = 
    Riot.Logger.set_log_level (Some Debug)
end

let () = Riot.start ~apps:[(module Riot.Logger)] ()
