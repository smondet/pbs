open Core.Std
open Result

module Command = struct

  type t = string

  let of_string (s : string)= (s : t)
  let to_string s = s

end

module Program = struct

  type t =
    | Sequence of Command.t list

  let command_sequence tl = Sequence tl

  let to_string = function
  | Sequence l -> String.concat ~sep:"\n" (List.map l Command.to_string)

end


type t = {
  header: string list;
  content: Program.t;
}

type emailing = [
  | `never
  | `always of string
]

let create
  ?name
  ?(shell="/bin/bash")
  ?(walltime=Time.Span.day)
  ?(email_user: emailing=`never)
  ?queue
  ?stderr_path
  ?stdout_path
  ?(nodes=1) ?(ppn=1) program =
  let header =
    let resource_list =
      let {Time.Span.Parts. hr; min; sec; _ } = Time.Span.to_parts walltime in
      sprintf "nodes=%d:ppn=%d,walltime=%02d:%02d:%02d" nodes ppn hr min sec in
    let opt o ~f = Option.value_map ~default:[] o ~f:(fun s -> [f s]) in

    List.concat [
      [sprintf "#! %s" shell];
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
  {header; content = program}

let to_string { header; content } =
  String.concat ~sep:"\n" header ^ "\n\n" ^ Program.to_string content ^ "\n"

let make_create how_to ?name ?shell ?walltime ?email_user ?queue
    ?stderr_path ?stdout_path ?nodes ?ppn arg =
  create ?name ?shell ?walltime ?email_user ?queue ?stderr_path
    ?stdout_path ?nodes ?ppn (how_to arg)

let sequence =
  make_create (fun sl -> Program.(Command.(command_sequence (List.map sl of_string))))

