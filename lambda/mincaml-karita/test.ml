let limit = ref 1000;;

let rec iter n e = (* 最適化処理をくりかえす (caml2html: main_iter) *)
  Format.eprintf "iteration %d@." n;
  if n = 0 then e else
  let e' = Elim.f (ConstFold.f (Inline.f (Assoc.f (Beta.f e)))) in
  if e = e' then e else
  iter (n - 1) e'
;;


let parse_syntax lexbuf = begin
    Id.counter := 0;
    Typing.extenv := M.empty;
     (Closure.f
	(iter !limit
	   (Alpha.f
	      (KNormal.f
		 (Typing.f
		    (Parser.exp Lexer.token lexbuf))))));
  end
;;

let parse_string s = parse_syntax (Lexing.from_string s);;

let make_sample s = (s,parse_string s);;

let sample1 = make_sample
"let a = let rec f x = x + 2 in f ( f ( 32)) in ()";;

let sample2 = make_sample
"
let top =
    let rec f x = x + 2 in
    let rec g x y = x + y in
    let rec h x = g 32 x in
    let rec a c = f ( f ( h 92)) in
    (a 10) in
print_int top
";;

let sample3 = make_sample
"
let top =
    let rec f x = x + 2 in
    let rec g x y = x + y in
    let z = g 100 20 in
    let rec h x = g z x in
    let rec a c = f ( f ( h z)) in
    (a 10) in
print_int top
";;
let sample4 = make_sample
"
let top =
    let rec f x = x + 2 in
    let rec g x y = x + y in
    let rec h x = g 32 x in
    let rec a c = if f 3 = h 4
      then f ( f ( h 92))
      else 0
    in
    (a 10) in
print_int top
";;
let sample5 = make_sample
"
let top =
    let rec f x = x + 2 in
    let rec g x y = x + y in
    let rec h x = g 32 x in
    let a = if f 3 = h 4
      then f ( f ( h 92))
      else 0
    in
    (f a) in
print_int top
";;

let sample6 = make_sample
"
let top =
    let rec f x = x + 2 in
    let rec g x y = x + y in
    let rec h x = x + x in
    let a = f 3 in
    if( (g 3 5) = (f 3)) then
      let b = (f 7) in
      if( (f 7) = (g (f 3) 9) ) then
        let c = f (10) in
        c + b + 100
      else
        let d = h (10) in
        (f a) + d
    else
      if( (g 3 5) = (f 3)) then
        g a a
      else
        f a
    in
print_int top
";;
let id x = x;;
let fold_string_with_sep sep f list = 
  List.fold_right (fun x y -> f x ^ sep ^ y) list "";;

(* uses function keyword to avoid spoiling polimorpism *)
let fold_string f list =  fold_string_with_sep " " f list;;

let fold_string_fst list =
  fold_string (function (a,b) -> a) list;;

let print_id_t t = t;;
let print_id_l   = function (Id.L name) -> name;;
let print_name_l f = print_id_l (fst f.Closure.name);;
let print_args f = fold_string_fst f.Closure.args ;;
let print_formal_fv f = fold_string_fst f.Closure.formal_fv ;;

let print_closure_closure c = "("^ print_id_l c.Closure.entry ^" $ " ^ fold_string id c.Closure.actual_fv ^")";;

let rec print_closure c = let unsupp = "unsupported" in match c with
  | Closure.Unit -> "()"
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
  | Closure.MakeCls ((t1,t2),c1,t3) -> "(["^print_closure_closure c1 ^ "] ->\n" ^ print_closure t3 ^ ")"
  | Closure.AppCls (v1,ts) -> "(*"^ v1 ^ " " ^ fold_string id ts ^ ")"
  | Closure.AppDir (v1,ts) -> "(+"^ print_id_l v1 ^ " " ^ fold_string id ts ^ ")"
  | Closure.Tuple (ts) -> "(tuple: "^ fold_string id ts ^ ")"
  | Closure.LetTuple (ids,v1,v2) -> "let "^ fold_string_fst ids ^ " = " ^ v1 ^ " in\n" ^ print_closure v2
  | Closure.Get(t1,i1) -> "("^t1^"["^i1^"])"
  | Closure.Put(t1,i1,t2) -> "("^t1^"["^i1^"]<-" ^t2^")"
  | Closure.ExtArray (l) -> "(ext "^ print_id_l l  ^")"

let print_fundef f =
  "let " ^ (print_name_l f) ^ " [" ^ print_formal_fv f ^ "] " ^ print_args f ^ " =\n  "
  ^ print_closure f.Closure.body
  ;;
    
let print_prog p = match p with
  Closure.Prog( plist, cl )->"\n####\n" ^
    fold_string_with_sep "\nand\n" print_fundef plist
    ^ print_closure cl ^ "\n####\n";;

let _ =  Printf.printf "%s\n" ( print_prog (snd sample1));;
let _ =  Printf.printf "%s\n" ( print_prog (snd sample2));;
let _ =  Printf.printf "%s\n" ( print_prog (snd sample3));;
let _ =  Printf.printf "%s\n" ( print_prog (snd sample4));;
let _ =  Printf.printf "%s\n" ( print_prog (snd sample5));;
let _ =  Printf.printf "%s\n" ( print_prog (snd sample6));;


(*
type closure = { entry : Id.l; actual_fv : Id.t list }
type t =
  | Unit
  | Int of int
  | Float of float
  | Neg of Id.t
  | Add of Id.t * Id.t
  | Sub of Id.t * Id.t
  | FNeg of Id.t
  | FAdd of Id.t * Id.t
  | FSub of Id.t * Id.t
  | FMul of Id.t * Id.t
  | FDiv of Id.t * Id.t
  | IfEq of Id.t * Id.t * t * t
  | IfLE of Id.t * Id.t * t * t
  | Let of (Id.t * Type.t) * t * t
  | Var of Id.t
  | MakeCls of (Id.t * Type.t) * closure * t
  | AppCls of Id.t * Id.t list
  | AppDir of Id.l * Id.t list
  | Tuple of Id.t list
  | LetTuple of (Id.t * Type.t) list * Id.t * t
  | Get of Id.t * Id.t
  | Put of Id.t * Id.t * Id.t
  | ExtArray of Id.l
type fundef = { name : Id.l * Type.t;
                args : (Id.t * Type.t) list;
                formal_fv : (Id.t * Type.t) list;
                body : t }
type prog = Prog of fundef list * t

*)

