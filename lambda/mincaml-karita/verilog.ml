
exception Unsupp

type exp  = Val of int | Var of Id.t | Neg of Id.t | Add of Id.t * Id.t | Sub of Id.t * Id.t | ModCall of Id.t * Id.t list
type cond = Eq of Id.t * Id.t | LE of Id.t * Id.t
type body = Seq of body * body | Choice of cond * body * body | Ass of Id.t * exp | Return of exp 
type seq  = SeqChoice of cond * seq list * seq list | SeqAss of Id.t * exp | SeqReturn of exp 

type env  = FunDef of Id.t * Id.t list | VarDef of Id.t

module M = Map.Make (
    struct 
      type t = Id.t
      let compare = Pervasives.compare
    end)

let rec body_to_seq_list = function
  | Seq (b1,b2) -> body_to_seq_list b1 @ body_to_seq_list b2
  | Choice ( c ,b1,b2) -> [SeqChoice(c,body_to_seq_list b1 , body_to_seq_list b2)]
  | Ass(t,e) -> [SeqAss(t,e)]
  | Return e -> [SeqReturn(e)]

let body_term env t =
      match env with
        | (FunDef _ :: _, _)   -> Return t
        | (VarDef name:: _, _) -> Ass ( name , t )
        | _            -> raise Not_found

let get_fv_list env t = (M.find t (snd env)).Closure.actual_fv
let push_varname (venv,cenv) name = (VarDef name :: venv,cenv)
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

