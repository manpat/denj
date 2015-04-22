SOURCE=$(wildcard *.d */*.d)

all: $(SOURCE)
	dmd $^ -ofbuild

run: all
	# @optirun ./build
	./build

clean:
	@rm ./build