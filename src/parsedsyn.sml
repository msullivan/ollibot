structure ParsedSyn :> PARSED_SYN = struct

open Pos
open Global

datatype 'e var_decl = Var of string * pos | VarTy of (string * pos) * 'e

datatype 'e exp_view = 
    Exists of 'e var_decl * 'e
  | Pi of 'e var_decl * 'e
  | Lam of 'e var_decl * 'e
  | App of 'e * 'e
  | Arrow of 'e * 'e
  | Pair of 'e * 'e      
  | UCid of string 
  | LCid of string
  | Eq of 'e * 'e
  | Type of kind

datatype 'a exp = Fix of ('a exp) exp_view * 'a

type pexp = pos exp
type decl =  (string option * pexp option * pexp option) * Pos.pos

structure E = 
MakeMTyp(struct
         type 'a t = 'a exp
         type 'e view = 'e exp_view
                        
         val f = fn (a,b) => a
         val s = fn (a,b) => b
         val inj = fn (obj, mark) => Fix (obj, mark)
         val prj = fn Fix (obj, mark) => (obj, mark)
         val map = 
          fn f => 
          fn Exists(Var x,e)        => Exists(Var x, f e)
           | Exists(VarTy(x,e1),e2) => Exists(VarTy(x,f e1),f e2)
           | Pi(VarTy(x,e1),e2)     => Pi(VarTy(x,f e1),f e2)
           | Pi(Var x,e)            => Pi(Var x, f e)
           | Lam(VarTy(x,e1),e2)    => Lam(VarTy(x,f e1),f e2)
           | Lam(Var x,e)           => Lam(Var x, f e)
           | App(e1,e2)             => App(f e1, f e2)
           | Arrow(e1,e2)           => Arrow(f e1, f e2)
           | Pair(e1,e2)            => Pair(f e1, f e2)
           | UCid s                 => UCid s
           | LCid s                 => LCid s
           | Eq(e1,e2)              => Eq(f e1, f e2)
           | Type s                 => Type s
         end)
open E

val Exists' = fn ((dec, pos1), e as Fix (_,pos2)) => 
                 Fix(Exists(dec,e), union(pos1,pos2))
val Pi'     = fn ((dec, pos1), e as Fix (_,pos2)) => 
                 Fix(Pi(dec,e), union(pos1,pos2))
val Lam'    = fn ((dec, pos1), e as Fix (_,pos2)) => 
                 Fix(Lam(dec,e), union(pos1,pos2))
val App'    = fn (e1 as Fix (_,pos1), e2 as Fix (_,pos2)) => 
                 Fix(App(e1,e2), union(pos1,pos2))
val Arrow'  = fn (e1 as Fix (_,pos1), e2 as Fix (_,pos2)) => 
                 Fix(Arrow(e1,e2), union(pos1,pos2))
val Pair'   = fn (e1 as Fix (_,pos1), e2 as Fix (_,pos2)) => 
                 Fix(Pair(e1,e2), union(pos1,pos2))
val UCid'   = fn (s,pos) => Fix(UCid s, pos)
val LCid'   = fn (s,pos) => Fix(LCid s, pos)
val Eq'     = fn (e1 as Fix (_,pos1), e2 as Fix (_,pos2)) => 
                 Fix(Eq(e1,e2), union(pos1,pos2))
val Type'   = fn (ppm,pos) => Fix(Type ppm, pos)

fun wrap(s,true) = "(" ^ s ^ ")"
  | wrap(s,false) = s

fun tos e = 
    fold
    (fn (e,pos) =>
        case e of 
          Exists(_,(e,_)) => 
          ("Exists " ^ e, false)
        | Pi(_,(e,_)) => 
          ("Pi " ^ e, false)
        | Lam(_,(e,_)) => 
          ("Lam " ^ e, false)
        | App(e1,e2) => 
          (wrap e1 ^ " " ^ wrap e2, true)
        | Arrow(e1,e2) =>
          (wrap e1 ^ " -> " ^ wrap e2, true)
        | Pair(e1,e2) => 
          (wrap e1 ^ "," ^ wrap e2, true)
        | UCid s => (s, false)
        | LCid s => (s, false)
        | Eq (e1,e2) => (wrap e1 ^ " == " ^ wrap e2, true)
        | Type k => ("type", false))
    e

fun to_string e = #1 (tos e)

fun to_string_paren e = wrap (tos e)

end
