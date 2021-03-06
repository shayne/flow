(**
 * Copyright (c) 2014, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the "flow" directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 *)

type message =
  | BlameM of Loc.t * string
  | CommentM of string
type error_kind =
  | ParseError
  | InferError
  | InferWarning
type error = {
  kind: error_kind;
  messages: message list;
  trace: message list;
}

type pp_message = Loc.t * string
val to_pp : message -> pp_message

type flags = {
  color: Tty.color_mode;
  one_line: bool;
  show_all_errors: bool;
  old_output_format: bool;
}

type stdin_file = (string * string) option

val default_flags : flags

val message_of_reason: Reason_js.reason -> message
val message_of_string: string -> message

val strip_root_from_errors: Path.t -> error list -> error list

val format_reason_color: ?first:bool -> ?one_line:bool -> message ->
  (Tty.style * string) list

val print_reason_color:
  first:bool ->
  one_line:bool ->
  color:Tty.color_mode ->
  message ->
  unit

val print_error_color_new:
  stdin_file:stdin_file ->
  one_line:bool ->
  color:Tty.color_mode ->
  root: Path.t ->
  error ->
  unit

val loc_of_error : error -> Loc.t

val json_of_loc : Loc.t -> (string * Hh_json.json) list

module Error :
  sig
    type t = error
    val compare : error -> error -> int
  end

(* we store errors in sets, currently, because distinct
   traces may share endpoints, and produce the same error *)
module ErrorSet : Set.S with type elt = error

module ErrorSuppressions : sig
  type t

  val empty : t
  val add : Loc.t -> t -> t
  val union : t -> t -> t
  val check : error -> t -> (bool * t)
  val unused : t -> Loc.t list
  val cardinal : t -> int
end

val parse_error_to_flow_error : (Loc.t * Parse_error.t) -> error

val to_list : ErrorSet.t -> error list

val json_of_errors : Error.t list -> Hh_json.json
val print_error_json : out_channel -> error list -> unit

(* Human readable output *)
val print_error_summary:
  flags:flags ->
  ?stdin_file:stdin_file ->
  root: Path.t ->
  error list ->
  unit

val string_of_loc_deprecated: Loc.t -> string
val print_error_deprecated: out_channel -> error list -> unit
