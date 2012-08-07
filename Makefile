all : test

test: test.vvp
	vvp $<

test.vvp: test.v
	mkdir -p tmp
	env TMP=./tmp iverilog $< -o $@

clean:
	rm -rfv *.vvp *.bak a.out *~
