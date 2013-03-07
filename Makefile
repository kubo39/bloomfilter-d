data : ex.d bloomfilter.d
	dmd $^

debug : ex.d bloomfilter.d
	dmd $^ -debug

test : ex
	./ex

clean :
	rm *.o bloomfilter