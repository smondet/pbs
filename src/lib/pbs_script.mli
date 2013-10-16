
module Command: sig

  type t

  val to_string: t -> string
  val of_string: string -> t

end

module Program: sig

  type t

  val command_sequence: Command.t list -> t
  val monitored_command_sequence: with_file:string -> Command.t list -> t
  val array_item: (string -> t) -> t

end

type t

type emailing = [
  | `Never
  | `Always of string
]

type array_index = [ `Index of int | `Range of int * int ]

type dependency = [
  | `After_ok of string
  | `After_not_ok of string
  | `After of string
]

type timespan = [
  | `Hours of float
]

val create :
  ?name:string ->
  ?shell:string ->
  ?walltime:timespan ->
  ?email_user:emailing ->
  ?queue:string ->
  ?stderr_path:string ->
  ?stdout_path:string ->
  ?array_indexes:array_index list ->
  ?dependencies:dependency list ->
  ?nodes:int -> ?ppn:int -> Program.t -> t


val sequence :
  ?name:string ->
  ?shell:string ->
  ?walltime:timespan ->
  ?email_user:emailing ->
  ?queue:string ->
  ?stderr_path:string ->
  ?stdout_path:string ->
  ?array_indexes:array_index list ->
  ?dependencies:dependency list ->
  ?nodes:int -> ?ppn:int -> string list -> t

val monitored_sequence:
  with_file:string ->
  ?name:string ->
  ?shell:string ->
  ?walltime:timespan ->
  ?email_user:emailing ->
  ?queue:string ->
  ?stderr_path:string ->
  ?stdout_path:string ->
  ?array_indexes:array_index list ->
  ?dependencies:dependency list ->
  ?nodes:int -> ?ppn:int -> string list -> t

val array_sequence:
  ?name:string ->
  ?shell:string ->
  ?walltime:timespan ->
  ?email_user:emailing ->
  ?queue:string ->
  ?stderr_path:string ->
  ?stdout_path:string ->
  ?array_indexes:array_index list ->
  ?dependencies:dependency list ->
  ?nodes:int -> ?ppn:int -> (string -> string list) -> t

val to_string: t -> string

