
module Command: sig

  type t

  include Core.Stringable.S with type t := t

end

module Program: sig

  type t

  val command_sequence: Command.t list -> t

end

type t

type emailing = [
  | `never
  | `always of string
]

val create :
  ?name:string ->
  ?shell:string ->
  ?walltime:Core.Std.Time.Span.t ->
  ?email_user:emailing ->
  ?queue:string ->
  ?stderr_path:string ->
  ?stdout_path:string ->
  ?nodes:int -> ?ppn:int -> Program.t -> t


val sequence :
  ?name:string ->
  ?shell:string ->
  ?walltime:Core.Std.Time.Span.t ->
  ?email_user:emailing ->
  ?queue:string ->
  ?stderr_path:string ->
  ?stdout_path:string ->
  ?nodes:int -> ?ppn:int -> string list -> t
