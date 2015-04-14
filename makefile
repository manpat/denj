SOURCE=$(wildcard *.d */*.d)

all: $(SOURCE)
	dmd $^ -ofbuild

run: all
	@optirun ./build

clean:
	@rm ./build