
exception Unsupp

type exp  = Val of int | Var of Id.t | Neg of Id.t | Add of Id.t * Id.t | Sub of Id.t * Id.t | ModCall of Id.t * Id.t list
type cond = Eq of Id.t * Id.t | LE of Id.t * Id.t
type body = Seq of body * body | Choice of cond * body * body | Ass of Id.t * exp | Return of exp 
type seq  = SeqC of int * cond * int * int | SeqA of int * Id.t * exp * int | SeqR of int * exp
type modl = Mod of Id.t * Id.t list * seq list

type env  = FunDef of Id.t * Id.t list | VarDef of Id.t


let empty_env = ([],M.empty)
let dummy_fundef_env      = ([FunDef("a",[])],M.empty)

let body_term env t =
      match env with
        | (FunDef _ :: _, _)   -> Return t
        | (VarDef name:: _, _) -> Ass ( name , t )
        | _            -> raise Not_found

let get_fv_list env t = (M.find t (snd env)).Closure.actual_fv
let push_varname (venv,cenv) name = (VarDef name :: venv,cenv)
let push_fundef  (venv,cenv) name arglist = (FunDef( name ,arglist):: venv,cenv)
let push_closure (venv,cenv) (key,value) = (venv,M.add key value cenv)

let rec closure_to_body env f  = 
  match f with
  | Closure.Unit  -> body_term env (Val 0)
  | Closure.Int i -> body_term env (Val i)
  | Closure.Float _ -> raise Unsupp
  | Closure.Neg t -> body_term env (Neg t)
  | Closure.Add (t1,t2) -> body_term env (Add (t1,t2))
  | Closure.Sub (t1,t2) -> body_term env (Sub (t1,t2))
  | Closure.FNeg  _ -> raise Unsupp
  | Closure.FAdd  _ -> raise Unsupp
  | Closure.FSub  _ -> raise Unsupp
  | Closure.FMul  _ -> raise Unsupp
  | Closure.FDiv  _ -> raise Unsupp
  | Closure.IfEq (c1,c2,t1,t2) -> Choice(Eq(c1,c2),closure_to_body env t1,closure_to_body env t2)
  | Closure.IfLE (c1,c2,t1,t2) -> Choice(LE(c1,c2),closure_to_body env t1,closure_to_body env t2)
  | Closure.Let ((v1,_),t1,t2) -> Seq(closure_to_body (push_varname env v1) t1,closure_to_body env t2)
  | Closure.Var t -> body_term env (Var t)
  | Closure.MakeCls ((t1,t2),c1,t3) -> closure_to_body (push_closure env (t1,c1)) t3
  | Closure.AppCls (v1,ts) -> body_term env (ModCall (v1, get_fv_list env v1 @ ts))
  | Closure.AppDir (Id.L v1,ts) ->  body_term env (ModCall (v1, ts))
  | Closure.Tuple (ts) -> raise Unsupp
  | Closure.LetTuple (ids,v1,v2) -> raise Unsupp
  | Closure.Get(t1,i1) -> raise Unsupp
  | Closure.Put(t1,i1,t2) -> raise Unsupp
  | Closure.ExtArray (l) -> raise Unsupp

module M = Map.Make (
    struct 
      type t = Id.t
      let compare = Pervasives.compare
    end)

let rec body_to_seq_list t c n = match t with
  | Seq (t1,t2) ->
      let (r2,(c2,n2)) = body_to_seq_list t2 c  n  in
      let (r1,(c1,n1)) = body_to_seq_list t1 c2 n2 in
      (r1@r2,(c1,n1))
  | Choice(cond,t1,t2) ->
      let (r2,(c2,n2)) = body_to_seq_list t2 c  n in
      let (r1,(c1,n1)) = body_to_seq_list t1 c2 n in
      (SeqC(c1+1,cond,c1,c2)::(r1@r2),(c1+1,c1+1))
  | Ass(i,e) -> (* suspicious. think more on Choice and Seq *)
      ([SeqA(c+1,i,e,n)],(c+1,c+1))
  | Return e -> (* suspicious. think more on Choice and Seq *)
      ([SeqR(c+1,e)],(c+1,c+1))

(* must think better *)
let fundef_to_module f = match fst f.Closure.name with | Id.L name ->
  let arglist = (List.map fst (f.Closure.formal_fv @ f.Closure.args))in
  let env     = push_fundef empty_env name arglist in
  let c1      = closure_to_body env f.Closure.body in
  Mod (name,arglist,fst (body_to_seq_list c1 0 0))
              

let prog_to_module = function Closure.Prog(fundef_list,main) ->
  let module_list = List.map (fun f-> fundef_to_module f) fundef_list in
  let main_func   = { (* forces main function wrap *)
        Closure.name=(Id.L ("main"),Type.Unit);
        Closure.args=[];
        Closure.formal_fv=[];
        body=main} in
  let main_module = fundef_to_module main_func in
  module_list @ [main_module]

(*
type fundef = { name : Id.l * Type.t;
                args : (Id.t * Type.t) list;
                formal_fv : (Id.t * Type.t) list;
                body : t }
type closure = { entry : Id.l; actual_fv : Id.t list }
type prog = Prog of fundef list * t

*)

(* samples *)
let make_sample c = let c1 = closure_to_body dummy_fundef_env c in (body_to_seq_list c1 0 0,c1)
let sample1  = prog_to_module (snd Test.sample1)
let sample2  = prog_to_module (snd Test.sample2)
(*
let sample3  = prog_to_module (snd Test.sample3)
*)
let sample4  = prog_to_module (snd Test.sample4)


