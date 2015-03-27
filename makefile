PROJECTNAME=`pwd | egrep -o "\w+$$"`

all: *.d */*.d
	dmd $^ -ofbuild

run: all
	@./build

clean:
	@rm ./build