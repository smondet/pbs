open Core.Std
open Flow

type t =  string * (string * string) list
(** The output of [parse_qstat]: ["Job official ID", (key, value) list]. *)

(** Parse the output of [qstat -f1 <job-id>] (for now this does not
     handle output for multiple jobs). *)
let parse_qstat (s: string) : (t, _) Core.Std.Result.t =
  let open Result in
  let option_or_fail e o =
    match o with Some s -> return s | None -> fail (`qstat e) in
  let lines =
    String.split ~on:'\n' s |! List.map ~f:String.strip
    |! List.filter ~f:((<>) "") in
  List.hd lines |! option_or_fail (`no_header s)
  >>= fun header ->
  String.lsplit2 header ~on:':' |! option_or_fail (`wrong_header_format header)
  >>| snd
  >>| String.strip
  >>= fun official_job_id ->
  List.tl lines |! option_or_fail (`no_header s)
  >>= fun actual_info ->
  let oks, errors =
    List.map actual_info (fun line ->
      String.lsplit2 line ~on:'=' |! option_or_fail (`wrong_line_format line)
      >>= fun (key, value) ->
      return (String.strip key, String.strip value))
    |! List.partition_map  ~f:(function | Ok o -> `Fst o | Error e -> `Snd e) in
  begin if errors <> []
    then
      fail (`qstat
          (`wrong_lines (List.map errors
               (function `qstat (`wrong_line_format s) -> s))))
    else return (official_job_id, oks)
  end

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
with sexp

(** Get the status of the job (this follows
    {{:http://linux.die.net/man/1/qstat-torque}the qstat-torque manpage}).*)
let get_status ((_, assoc): t) =
  let open Result in
  let fail e = fail (`qstat e) in
  match List.Assoc.find assoc "job_state" with
  | Some "R" -> return `running
  | Some "Q" -> return `queued
  | Some "C" -> return `completed
  | Some "E" -> return `exiting
  | Some "H" -> return `held
  | Some "T" -> return `moved
  | Some "W" -> return `waiting
  | Some "S" -> return `suspended
  | Some s -> fail (`unknown_status s)
  | None -> fail `job_state_not_found

let job_id (name, _) = name

let raw_field (_, assoc) field = List.Assoc.find assoc field

