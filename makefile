SOURCE=$(wildcard *.d */*.d)

all: $(SOURCE)
	dmd $^ -ofbuild

run: all
	@./build

clean:
	@rm ./build