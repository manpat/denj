module denj.math.matrix;

import std.math;
import denj.math.vector;

// Column major

// format                        
//     xx xy xz 0
//     yx yy yz 0
//     zx zy zz 0
//     tx ty tz 1

struct Matrix(int Columns, int Rows, T = float) {
	alias Matrix!(Columns, Rows, T) thisType;

	public {
		T[Columns * Rows] data;

		ref T get(int x, int y)() {
			static assert(x < Columns);
			static assert(y < Rows);

			return data[x + y * Rows];
		}

		ref T get(int x, int y) {
			return data[x + y * Rows];
		}
		T get(int x, int y) const {
			return data[x + y * Rows];
		}
	}

	this(T[Columns * Rows] _data){
		data[] = _data[];
	}
	this(T[Columns * Rows] _data...){
		data[] = _data[];
	}

	ref T opIndex(size_t x, size_t y){
		assert(x < Columns);
		assert(y < Rows);

		return data[x + y * Columns];		
	}

	T opIndex(size_t x, size_t y) const {
		assert(x < Columns);
		assert(y < Rows);

		return data[x + y * Columns];		
	}

	auto opBinary(string op, int RHSColumns, int RHSRows, RHST)(auto ref Matrix!(RHSColumns, RHSRows, RHST) rhs) const{
		alias typeof(T() * RHST()) ElType;
		alias Matrix!(RHSColumns, Rows, typeof(data[0]*rhs.data[0])) RetType;

		static if(op == "*"){
			static assert(Columns == RHSRows, "Matrices not able to be multiplied");
			RetType ret;

			foreach(i; 0..Rows)
				foreach(j; 0..RHSColumns){
					ElType sum = 0;

					foreach(k; 0..RHSRows){
						sum += get(k, i) * rhs[j, k];
					}
					
					ret[j, i] = sum; 
				}

			return ret;
		}else{
			static assert(0, "matrix "~op~" operation not implemented");
		}
	}

	string toString() const {
		import std.string : format;

		string s = format("[%(%s, %)", data[0..Rows]);
		foreach(y; 1..Rows){
			s ~= format(",\n %(%s, %)", data[y*Rows .. (y+1)*Rows]);
		}

		return s ~ "]";
	}

	static if(Columns == Rows){
		static if(Columns == 2){
			enum thisType identity = thisType(1, 0, 0, 1);

		}else static if(Columns == 3){
			enum thisType identity = thisType(1, 0, 0, 0, 1, 0, 0, 0, 1);

		}else static if(Columns == 4){
			enum thisType identity = thisType(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
		}
	}
}

alias Matrix!(2, 2) mat2;
alias Matrix!(3, 3) mat3;
alias Matrix!(4, 4) mat4;