all : test

test: test1.vvp
	vvp $<

.v.vvp:
	mkdir -p tmp
	env TMP=./tmp iverilog $< -o $@

.SUFFIXES: .vvp .v

clean:
	rm -rfv *.vvp *.bak a.out *~
