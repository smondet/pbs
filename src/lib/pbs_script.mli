
module Command: sig

  type t

  include Core.Stringable.S with type t := t

end

module Program: sig

  type t

  val command_sequence: Command.t list -> t

end

type t

val basic :
  ?name:string ->
  ?shell:string ->
  ?walltime:Core.Std.Time.Span.t ->
  ?email_user:[< `always of string | `never > `never ] ->
  ?queue:string ->
  ?stderr_path:string ->
  ?stdout_path:string ->
  ?nodes:int -> ?ppn:int -> Program.t -> t
