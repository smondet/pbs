open Core.Std
open Flow

let test_parsing () =
  let open Result in
  let fail_test fmt = ksprintf (fun s -> fail (`test_failure s)) fmt in
  let s1 = "\
Job Id: 1526443.crunch.local\n\
    Job_Name = The Job Name\n\
    Job_Owner = seb@somecluster.edu\n\
    resources_used.cput = 11:55:55\n\
    resources_used.mem = 514348kb\n\
    resources_used.vmem = 2924268kb\n\
    resources_used.walltime = 01:47:06\n\
    job_state = R\n\
    queue = some-queue\n\
    server = local_server\n\
    Checkpoint = disabled\n\
    " in
  Pbs_qstat.parse_qstat s1
  >>= fun qstat ->
  Pbs_qstat.get_status  qstat >>= begin function
  | `Running -> return ()
  | other ->
    fail_test "s1, get_status: wrong status: %s"
      (Pbs_qstat.sexp_of_status other |> Sexp.to_string_hum)
  end

let () =
  match test_parsing () with
  | Ok () -> eprintf "Done.\n%!"
  | Error e ->
    eprintf "TEST FAILED:\n%s\n%!"
      (e |>
       <:sexp_of<
         [> `qstat of
              [> `job_state_not_found
               | `no_header of string
               | `unknown_status of string
               | `wrong_header_format of Core.Std.String.t
               | `wrong_lines of Core.Std.String.t Core.Std.List.t ]
          | `test_failure of string ]
       >> |> Sexp.to_string_hum)
