

let module_to_verilog m = "module "

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
