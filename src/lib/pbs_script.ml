open Core.Std
open Result

module Command = struct

  type t = string

  let of_string s = s
  let to_string s = s

end

module Program = struct

  type t =
    | Sequence of Command.t list

  let command_sequence tl = Sequence tl

end


type t = {
  header: string list;
  content: Program.t;
}


let basic
  ?name
  ?(shell="/bin/bash")
  ?(walltime=Time.Span.day)
  ?(email_user=`never)
  ?queue
  ?stderr_path
  ?stdout_path
  ?(nodes=1) ?(ppn=1) content =
  let header =
    let resource_list =
      let {Time.Span.Parts. hr; min; sec; _ } = Time.Span.to_parts walltime in
      sprintf "nodes=%d:ppn=%d,walltime=%d:%d:%d" nodes ppn hr min sec in
    let opt o ~f = Option.value_map ~default:[] o ~f:(fun s -> [s]) in

    List.concat [
      [sprintf "#! %s!" shell];
      begin match email_user with
      | `never -> []
      | `always email -> ["#PBS -m abe"; sprintf "#PBS -M %s" email]
      end;
      [sprintf "#PBS -l %s" resource_list];
      opt stderr_path ~f:(sprintf "#PBS -e %s");
      opt stdout_path ~f:(sprintf "#PBS -o %s");
      opt name ~f:(sprintf "#PBS -N %s");
      opt queue ~f:(sprintf "#PBS -q %s");
    ]
  in
  {header; content}
