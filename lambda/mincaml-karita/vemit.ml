
type block = {reglist:Id.t list;wirelist:Id.t list;decls:string;body:string}

(* for module itself *)
let string_of_id_t id_t = "MINCAML_ID_" ^ id_t
let string_of_modret      modname = "MINCAML_MOD_RET_" (* reg *)
let string_of_modout      modname = "MINCAML_MOD_OUT_" (* reg *)
let string_of_mod_in      modname = "MINCAML_MOD__IN_" (* wire *)
let string_of_modclock      modname = "MINCAML_MOD_CLOCK_" (* wire *)
let string_of_modreset      modname = "MINCAML_MOD_RESET_" (* wire *)

(* for module call *)
let string_of_modcall_ret modname = "MINCAML_MODRET_"^modname
let string_of_modcall_arg modname = "MINCAML_MODARG_"^modname
let string_of_modcall_in  modname = "MINCAML_MOD_IN_"^modname
let string_of_modcall_out modname = "MINCAML_MODOUT_"^modname

let string_of_status_var = "MINCAML_INTERNAL_status";;

let modulename_stub = "TMP"

let seqc_body index c b1 b2 =
       begin
         match c with
         | Vmod.Eq (v1,v2) ->
             "case " ^ string_of_int index ^ ":\n begin\n"
           ^ "  if(" ^string_of_id_t v1 ^ " == " ^string_of_id_t v2 ^ v2 ^ " ) begin\n"
           ^ "    " ^ string_of_status_var ^ " = " ^ string_of_int b1 ^ ";\n"
           ^ "  else begin\n"
           ^ "    " ^ string_of_status_var ^ " = " ^ string_of_int b2 ^ ";\n"
           ^ "  end\n"
         | Vmod.LE (v1,v2) ->
             "case " ^ string_of_int index ^ ":\n begin\n"
           ^ "  if(" ^string_of_id_t v1 ^ " <= " ^string_of_id_t v2 ^ v2 ^ " ) begin\n"
           ^ "    " ^ string_of_status_var ^ " = " ^ string_of_int b1 ^ ";\n"
           ^ "  else begin\n"
           ^ "    " ^ string_of_status_var ^ " = " ^ string_of_int b2 ^ ";\n"
           ^ "  end\n"
       end

let block_of_simple_exp term retv finish =
  {
       reglist=[];
       wirelist=[];
       decls="";
       body="begin\n"
         ^ retv ^ " = " ^ term ^ ";\n"
         ^ finish
         ^ "end\n"
  }
let block_of_modcall (v,args)  retv finish =
  let modcall_args = let c = ref 0 in
    List.map (fun n->string_of_modcall_arg (v^string_of_int ( c:=!c+1;!c ))) args in
  let modcall_ret  = string_of_modcall_ret v in
  let modcall_in   = string_of_modcall_in  v in
  let modcall_out  = string_of_modcall_out v in
  {
       reglist= modcall_in::modcall_args; 
       wirelist= [modcall_ret;modcall_out];
       decls=""; (* module wire needed *)
       body=
         let b = List.fold_right (fun (a,v1) str -> a ^ " <= "^ v1 ^ ";\n" ^ str) (List.combine modcall_args args) "" in
               "begin\n"
             ^ b
             ^ "" ^ modcall_in ^ " = 1;\n"
             ^ "if( " ^ modcall_out ^ " == 1 ) begin\n"
             ^ "" ^ retv ^ " = " ^ modcall_ret ^ ";\n"
             ^ finish 
             ^ "end\n"
             ^ "end\n"
  }

(* get blocks without finishblow *)
let block_of_exp exp retv finish =
  match exp with
  | Vmod.Val i -> block_of_simple_exp (string_of_int i) retv finish
  | Vmod.Var v -> block_of_simple_exp v retv finish
  | Vmod.Neg v -> block_of_simple_exp (" - " ^ v) retv finish
  | Vmod.Add( v1, v2) -> block_of_simple_exp (v1 ^ " + " ^ v2) retv finish
  | Vmod.Sub( v1, v2) -> block_of_simple_exp (v1 ^ " - " ^ v2) retv finish
  | Vmod.ModCall (v,args) -> block_of_modcall (v,args) retv finish


let block_of_seq = function
  | Vmod.SeqC (index,c,b1,b2) ->
     {
       reglist=[];
       wirelist=[];
       decls="";
       body= seqc_body index c b1 b2;
     }
  | Vmod.SeqA (index,id_t,exp,b) ->
     let finish = (""^string_of_status_var^" = " ^ (string_of_int b) ^ ";\n") in
     let r = block_of_exp exp id_t  finish in
     let body_r =
         "begin\n"
       ^ r.body
       ^ "end\n"
     in
     {
       reglist=r.reglist;
       wirelist=r.wirelist;
       decls=r.decls;
       body=body_r
     }
  | Vmod.SeqR (index,exp) ->
     let finish = 
         string_of_status_var ^" = 0;\n"
       ^ string_of_modout modulename_stub ^ " = 1;\n"
     in
     let r = block_of_exp exp (string_of_modret modulename_stub) finish in
     let body_r =
         "begin\n"
       ^ r.body
       ^ "end\n"
     in
     {
       reglist=r.reglist;
       wirelist=r.wirelist;
       decls=r.decls;
       body=body_r
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
