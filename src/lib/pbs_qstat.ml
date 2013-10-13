open Pbs_internal_pervasives

type t =  string * (string * string) list
(** The output of [parse_qstat]: ["Job official ID", (key, value) list]. *)

(** TODO: handle output for multiple jobs. *)
let parse_qstat (s: string) : (t, _) Pvem.Result.t =
  let open Result in
  let some_or_fail e o =
    match o with Some s -> return s | None -> fail (`qstat e) in
  let lines =
    String.split ~on:(`Character '\n') s
    |> List.map ~f:String.strip
    |> List.filter ~f:((<>) "") in
  List.hd lines |> some_or_fail (`no_header s)
  >>= fun header ->
  some_or_fail (`wrong_header_format header)
    Option.(String.index_of_character header ':'
            >>= fun index ->
            String.sub header ~index:(index + 1)
              ~length:(String.length header - index - 1))
  >>| String.strip
  >>= fun official_job_id ->
  List.tl lines |> some_or_fail (`no_header s)
  >>= fun actual_info ->
  let oks, errors =
    List.map actual_info (fun line ->
        some_or_fail (`wrong_line_format line)
          Option.(String.index_of_character line '='
                  >>= fun index ->
                  (* dbg "line %s\n   index: %d" line index; *)
                  String.sub line ~index:0 ~length:(index - 1)
                  >>= fun key ->
                  String.sub line ~index:(index + 1)
                    ~length:(String.length line - index - 1)
                  >>= fun value ->
                  return (String.strip key, String.strip value)))
    |> List.partition_map  ~f:(function | `Ok o -> `Fst o | `Error e -> `Snd e)
  in
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

(** Get the status of the job (this follows
    {{:http://linux.die.net/man/1/qstat-torque}the qstat-torque manpage}).*)
let get_status ((_, assoc): t) =
  let open Result in
  let fail e = fail (`qstat e) in
  match List.find assoc (fun (k, _) -> k = "job_state") with
  | Some (_, "R") -> return `running
  | Some (_, "Q") -> return `queued
  | Some (_, "C") -> return `completed
  | Some (_, "E") -> return `exiting
  | Some (_, "H") -> return `held
  | Some (_, "T") -> return `moved
  | Some (_, "W") -> return `waiting
  | Some (_, "S") -> return `suspended
  | Some (_, s) -> fail (`unknown_status s)
  | None -> fail `job_state_not_found

let job_id (name, _) = name

let raw_field (_, assoc) field = 
  List.find assoc (fun (k, _) -> k = field)
  |> Option.map ~f:snd

let status_to_string_hum = function
| `completed   -> "completed"
| `exiting     -> "exiting"
| `held        -> "held"
| `moved       -> "moved"
| `queued      -> "queued"
| `running     -> "running"
| `suspended   -> "suspended"
| `waiting     -> "waiting"
