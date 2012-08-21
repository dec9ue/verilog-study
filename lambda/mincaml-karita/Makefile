	

sub1:
	ocamlc -c -g test.ml
	ocamlc -c -g vmod.ml
all: test.cmo
sub2:
	ocamllex  lexer.mll
	ocamlyacc  parser.mly
	ocamlc -c -g type.ml
	ocamlc -c -g id.ml
	ocamlc -c -g m.ml
	ocamlc -c -g s.ml
	ocamlc -c -g syntax.ml
	ocamlc -c -g parser.mli
	ocamlc -c -g parser.ml
	ocamlc -c -g lexer.ml
	ocamlc -c -g typing.mli
	ocamlc -c -g typing.ml
	ocamlc -c -g kNormal.mli
	ocamlc -c -g kNormal.ml
	ocamlc -c -g alpha.mli
	ocamlc -c -g alpha.ml
	ocamlc -c -g closure.mli
	ocamlc -c -g closure.ml
	ocamlc -c -g beta.mli
	ocamlc -c -g beta.ml
	ocamlc -c -g assoc.mli
	ocamlc -c -g assoc.ml 
	ocamlc -c -g inline.mli 
	ocamlc -c -g inline.ml 
	ocamlc -c -g constFold.mli 
	ocamlc -c -g constFold.ml 
	ocamlc -c -g elim.mli 
	ocamlc -c -g elim.ml 

.mly.ml:
	ocamlyacc $<
.mll.ml:
	ocamllex $<
.ml.cmo:
	ocamlc -c -g $<
.mli.cmi:
	ocamlc -c -g $<

.SUFFIXES: .ml .mli .cmo .cmi .mly .mll


alpha.cmo: m.cmo kNormal.cmi id.cmo alpha.cmi
alpha.cmx: m.cmx kNormal.cmx id.cmx alpha.cmi
anchor.cmo:
anchor.cmx:
assoc.cmo: kNormal.cmi assoc.cmi
assoc.cmx: kNormal.cmx assoc.cmi
beta.cmo: m.cmo kNormal.cmi beta.cmi
beta.cmx: m.cmx kNormal.cmx beta.cmi
closure.cmo: type.cmo s.cmo m.cmo kNormal.cmi id.cmo closure.cmi
closure.cmx: type.cmx s.cmx m.cmx kNormal.cmx id.cmx closure.cmi
constFold.cmo: m.cmo kNormal.cmi constFold.cmi
constFold.cmx: m.cmx kNormal.cmx constFold.cmi
elim.cmo: s.cmo kNormal.cmi id.cmo elim.cmi
elim.cmx: s.cmx kNormal.cmx id.cmx elim.cmi
id.cmo: type.cmo
id.cmx: type.cmx
inline.cmo: m.cmo kNormal.cmi alpha.cmi inline.cmi
inline.cmx: m.cmx kNormal.cmx alpha.cmx inline.cmi
kNormal.cmo: typing.cmi type.cmo syntax.cmo s.cmo m.cmo id.cmo kNormal.cmi
kNormal.cmx: typing.cmx type.cmx syntax.cmx s.cmx m.cmx id.cmx kNormal.cmi
lexer.cmo: type.cmo parser.cmi id.cmo
lexer.cmx: type.cmx parser.cmx id.cmx
m.cmo: id.cmo
m.cmx: id.cmx
main.cmo: virtual.cmi typing.cmi simm.cmi regAlloc.cmi parser.cmi m.cmo \
    lexer.cmo kNormal.cmi inline.cmi id.cmo emit.cmi elim.cmi constFold.cmi \
    closure.cmi beta.cmi assoc.cmi alpha.cmi main.cmi
main.cmx: virtual.cmi typing.cmx simm.cmi regAlloc.cmi parser.cmx m.cmx \
    lexer.cmx kNormal.cmx inline.cmx id.cmx emit.cmi elim.cmx constFold.cmx \
    closure.cmx beta.cmx assoc.cmx alpha.cmx main.cmi
parser.cmo: type.cmo syntax.cmo id.cmo parser.cmi
parser.cmx: type.cmx syntax.cmx id.cmx parser.cmi
s.cmo: id.cmo
s.cmx: id.cmx
syntax.cmo: type.cmo id.cmo
syntax.cmx: type.cmx id.cmx
test.cmo: typing.cmi parser.cmi m.cmo lexer.cmo kNormal.cmi inline.cmi id.cmo \
    elim.cmi constFold.cmi closure.cmi beta.cmi assoc.cmi alpha.cmi
test.cmx: typing.cmx parser.cmx m.cmx lexer.cmx kNormal.cmx inline.cmx id.cmx \
    elim.cmx constFold.cmx closure.cmx beta.cmx assoc.cmx alpha.cmx
test2.cmo:
test2.cmx:
type.cmo:
type.cmx:
typing.cmo: type.cmo syntax.cmo m.cmo typing.cmi
typing.cmx: type.cmx syntax.cmx m.cmx typing.cmi
