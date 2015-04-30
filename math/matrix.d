module denj.math.matrix;

import std.math;
import std.algorithm : min, max;
import denj.math.vector;

// Column major

// format                        
//     xx xy xz 0
//     yx yy yz 0
//     zx zy zz 0
//     tx ty tz 1

template isMat(T){
	enum isMat = is(T == Matrix!(C, R, sT), int C, int R, sT);
}

struct Matrix(int _Columns, int _Rows, T = float) {
	alias Matrix!(_Columns, _Rows, T) thisType;
	enum Columns = _Columns;
	enum Rows = _Rows;
	alias BaseType = T;

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

	static thisType Scale(T s){
		thisType ret = thisType.identity;
		foreach(i; 0..min(min(Columns, Rows), 3)){
			ret[i,i] = s;
		}

		return ret;
	}

	static if(Columns == 4 && Rows >= 3)
	static thisType Translation(vec3 t) {
		thisType ret = thisType.identity;
		ret[Columns-1, 0] = t.data[0];
		ret[Columns-1, 1] = t.data[1];
		ret[Columns-1, 2] = t.data[2];

		return ret;
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

	auto opBinary(string op)(auto ref T rhs) const{
		static if(op == "*"){
			thisType ret;
			ret.data[] = data[] * rhs;
			return ret;
		}else{
			static assert(0, "matrix "~op~" operation not implemented");
		}
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