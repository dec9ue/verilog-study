
type variable = int * string;
type port = Input of variable | Output of variable
type def = Wire of variable | Reg of variable
type conect = {modname: string; instname : string; args : variable list}
type body =   Arith of arith * body | ModCall of modcall * body | Choice of cond * body * body | Return of ret

type module = Module of port list * def list * connect * body

let closure_to_body env f = 
  | Closure.Unit -> 
  | Closure.Int i -> string_of_int i
  | Closure.Float _ -> unsupp
  | Closure.Neg  t -> " - " ^ t
  | Closure.Add (t1,t2) -> " "^t1^" + "^t2
  | Closure.Sub (t1,t2) -> " "^t1^" - "^t2
  | Closure.FNeg  _ -> unsupp
  | Closure.FAdd  _ -> unsupp
  | Closure.FSub  _ -> unsupp
  | Closure.FMul  _ -> unsupp
  | Closure.FDiv  _ -> unsupp
  | Closure.IfEq (c1,c2,t1,t2) -> "if " ^ c1 ^ " == " ^ c2 ^ "\n then " ^ print_closure t1 ^ "\n else " ^ print_closure t2
  | Closure.IfLE (c1,c2,t1,t2) -> "if " ^ c1 ^ " <= " ^ c2 ^ "\n then " ^ print_closure t1 ^ "\n else " ^ print_closure t2
  | Closure.Let ((v1,_),t1,t2)   -> "let " ^ v1 ^ " = " ^ print_closure t1 ^ " in\n" ^ print_closure t2
  | Closure.Var t -> t
  | Closure.MakeCls ((t1,t2),c1,t3) -> unsupp (*"("^t1^of (Id.t * Type.t) * closure * t *)
  | Closure.AppCls (v1,ts) -> "("^ v1 ^ " " ^ fold_string id ts ^ ")"
  | Closure.AppDir (v1,ts) -> "("^ print_id_l v1 ^ " " ^ fold_string id ts ^ ")"
  | Closure.Tuple (ts) -> "(tuple: "^ fold_string id ts ^ ")"
  | Closure.LetTuple (ids,v1,v2) -> "let "^ fold_string_fst ids ^ " = " ^ v1 ^ " in\n" ^ print_closure v2
  | Closure.Get(t1,i1) -> "("^t1^"["^i1^"])"
  | Closure.Put(t1,i1,t2) -> "("^t1^"["^i1^"]<-" ^t2^")"
  | Closure.ExtArray (l) -> "(ext "^ print_id_l l  ^")"


