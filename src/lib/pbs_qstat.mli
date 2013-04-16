(** Manage the output of [qstat]. *)

type t
(** The “raw” contents of per-job statistics. *)


val parse_qstat :
  string ->
  (t,
   [> `qstat of
        [> `no_header of string
        | `wrong_header_format of Core.Std.String.t
        | `wrong_lines of Core.Std.String.t Core.Std.List.t ] ])
    Core.Std.Result.t
(** Parse the output of [qstat -f1 <job-id>] (for now this does not
    handle output for multiple jobs).

    Note that the ["-1"] option is not POSIX but “seems” necessary (see
    {{:http://pubs.opengroup.org/onlinepubs/9699919799/utilities/qstat.html}OpenGroup/qstat}).
*)

type status = [
  | `Completed
  | `Exiting
  | `Held
  | `Moved
  | `Queued
  | `Running
  | `Suspended
  | `Waiting
]
(** High-level representation of a status. *)

val get_status :
  t ->
  (status,
   [> `qstat of
        [> `job_state_not_found | `unknown_status of string ] ])
    Core.Std.Result.t
(** Get the status of the job (this follows
    {{:http://linux.die.net/man/1/qstat-torque}the qstat-torque manpage}).*)

(** {2 Serialization } *)

val status_of_sexp: Core.Std.Sexp.t -> status
val sexp_of_status: status -> Core.Std.Sexp.t
