SOURCE=$(wildcard *.d */*.d)

build: $(SOURCE)
	dmd $^ -ofbuild

run: build
	# @optirun ./build
	./build

clean:
	@rm ./build