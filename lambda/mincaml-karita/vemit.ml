
type block = {reglist:Id.t list;wirelist:Id.t list;body=string}

let string_of_id_t id_t = "MINCAML_ID_" ^ id_t

let string_of_status_var = "MINCAML_INTERNAL_status";

let seqc_body index c b1 b2 =
       begin
         match c with
         | Eq (v1,v2) ->
             "case " ^ string_of_int index ^ ":\n begin\n"
           ^ "  if(" ^string_of_id_t v1 ^ " == " ^string_of_id_t v2 ^ v2 ^ " ) begin\n"
           ^ "    " ^ string_of_status_var ^ " = " ^ b1 ^ ";\n"
           ^ "  else begin\n"
           ^ "    " ^ string_of_status_var ^ " = " ^ b2 ^ ";\n"
           ^ "  end\n"
         | LE (v1,v2) ->
             "case " ^ string_of_int index ^ ":\n begin\n"
           ^ "  if(" ^string_of_id_t v1 ^ " <= " ^string_of_id_t v2 ^ v2 ^ " ) begin\n"
           ^ "    " ^ string_of_status_var ^ " = " ^ b1 ^ ";\n"
           ^ "  else begin\n"
           ^ "    " ^ string_of_status_var ^ " = " ^ b2 ^ ";\n"
           ^ "  end\n"
       end

let block_of_seq = function
  | Vmod.SeqC (index,c,b1,b2) ->
     {
       body= seq_c_body index c b1 b2;
       reglist=[];
       wirelist=[];
     }
  | Vmod.SeqA (index,id_t,exp,b) ->

let block_of_modcall modcall =
  {
       body= seq_c_body index c b1 b2;
       reglist=[];
       wirelist=[];
  }


(*
  
exception Unsupp

type exp  = Val of int | Var of Id.t | Neg of Id.t | Add of Id.t * Id.t | Sub of Id.t * Id.t | ModCall of Id.t * Id.t list
type cond = Eq of Id.t * Id.t | LE of Id.t * Id.t
type seq  = SeqC of int * cond * int * int | SeqA of int * Id.t * exp * int | SeqR of int * exp
type vmod = Mod of Id.t * Id.t list * seq list

val prog_to_module : Closure.prog -> vmod list

val sample1 : vmod list
val sample2 : vmod list
val sample4 : vmod list
val sample5 : vmod list
val sample6 : vmod list


*)
