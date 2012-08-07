all : test

test: test.vvp
	vvp $<

test.vvp: test.v
	iverilog $< -o $@

clean:
	rm -rfv *.vvp *.bak a.out *~
