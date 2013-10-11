
module String = Sosa.Native_string
include Nonstd

include Pvem


let dbg fmt =
  ksprintf (fun s -> printf "PBS-DEBUG: %s\n%!" s) fmt
