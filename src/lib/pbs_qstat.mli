(** Manage the output of [qstat]. *)

type t
(** The “raw” contents of per-job statistics. *)


val parse_qstat :
  string ->
  (t,
   [> `qstat of
        [> `no_header of string
        | `wrong_header_format of String.t
        | `wrong_lines of String.t list ] ])
    Pvem.Result.t
(** Parse the output of [qstat -f1 <job-id>] (for now this does not
    handle output for multiple jobs).

    Note that the ["-1"] option is not POSIX but “seems” necessary (see
    {{:http://pubs.opengroup.org/onlinepubs/9699919799/utilities/qstat.html}OpenGroup/qstat}).
*)

type status = [
  | `completed
  | `exiting
  | `held
  | `moved
  | `queued
  | `running
  | `suspended
  | `waiting
]
(** High-level representation of a status. *)

val get_status :
  t ->
  (status,
   [> `qstat of
        [> `job_state_not_found | `unknown_status of string ] ])
    Pvem.Result.t
(** Get the status of the job (this follows
    {{:http://linux.die.net/man/1/qstat-torque}the qstat-torque manpage}).*)

val job_id: t -> string
(** Get the “official PBS job ID” of the given job. *)

val raw_field: t -> string -> string option
(** Find a field in the output of [qstat]. *)

val status_to_string_hum: status -> string
(** Get a human-readable string for a given status. *)

val error_to_string :
  [< `qstat of
       [< `job_state_not_found
       | `no_header of string
       | `unknown_status of string
       | `wrong_header_format of string
       | `wrong_lines of string list ] ] -> string
(** Get a human-readable representation of an error in this module. *)
