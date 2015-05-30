module denj.math.matrix;

import std.math;
import std.algorithm : min, max;
import denj.utility.general;
import denj.math.vector;

// Column major

// format                        
//     xx yx zx tx
//     xy yy zy ty
//     xz yz zz tz
//     0  0  0  1

// http://www.gamedev.net/topic/425118-inverse--matrix/

template isMat(T){
	enum isMat = is(T == Matrix!(C, R, sT), int C, int R, sT);
}

// TODO: implement right binary op for vector
struct Matrix(int _Columns, int _Rows, T = float) {
	alias Matrix!(_Columns, _Rows, T) thisType;
	alias Matrix!(_Rows, _Columns, T) transposeType;
	enum Columns = _Columns;
	enum Rows = _Rows;
	alias BaseType = T;

	public {
		T[Columns * Rows] data;

		ref T get(int x, int y)() {
			static assert(x < Columns);
			static assert(y < Rows);

			return data[x + y * Columns];
		}

		ref T get(int x, int y) {
			return data[x + y * Columns];
		}
		T get(int x, int y) const {
			return data[x + y * Columns];
		}
		@property T* ptr(){
			return data.ptr;
		}
	}

	this(T[Columns * Rows] _data){
		data[] = _data[];
	}
	this(T[Columns * Rows] _data...){
		data[] = _data[];
	}

	// Available for every dimension
	static thisType Scale(T s){
		thisType ret = thisType.identity;
		foreach(i; 0..min(min(Columns, Rows), 3)){
			ret[i,i] = s;
		}

		return ret;
	}

	// Requires a fourth column and at least three rows
	static if(Columns == 4 && Rows >= 3)
	static auto Translation(vec3 t) {
		thisType ret = thisType.identity;
		ret[Columns-1, 0] = t.data[0];
		ret[Columns-1, 1] = t.data[1];
		ret[Columns-1, 2] = t.data[2];

		return ret;
	}

	static if(Columns >= 3 && Rows == 4)
	auto Translate(vec3 t) {
		return transposeType.Translation(t) * this;
	}

	// Requires at least 2x2
	//	Rotations in lower dimensions don't make sense
	static if(Columns >= 2 && Rows >= 2){
		static auto ZRotation(float ang){
			auto ret = thisType.identity;
			float ca = cos(ang);
			float sa = sin(ang);
			ret[0, 0] = ca;
			ret[1, 1] = ca;
			ret[0, 1] = sa;
			ret[1, 0] = -sa;
			return ret;
		}
		
		auto RotateZ(float ang){
			return transposeType.ZRotation(ang) * this;
		}
	}

	// Requires three dimensions
	static if(Columns >= 3 && Rows >= 3){
		static auto YRotation(float ang){
			auto ret = thisType.identity;
			float ca = cos(ang);
			float sa = sin(ang);
			ret[0, 0] = ca;
			ret[2, 2] = ca;
			ret[0, 2] = -sa;
			ret[2, 0] = sa;
			return ret;
		}

		auto RotateY(float ang){
			return transposeType.YRotation(ang) * this;
		}

		static auto XRotation(float ang){
			auto ret = thisType.identity;
			float ca = cos(ang);
			float sa = sin(ang);
			ret[1, 1] = ca;
			ret[2, 2] = ca;
			ret[1, 2] = sa;
			ret[2, 1] = -sa;
			return ret;
		}

		auto RotateX(float ang){
			return transposeType.XRotation(ang) * this;
		}
	}

	auto Transposed(){
		transposeType ret = void;

		foreach(uint x; 0..Columns)
			foreach(uint y; 0..Rows){
				ret[y,x] = get(x,y);
			}

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
		alias Matrix!(RHSColumns, Rows, ElType) RetType;

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

	auto opBinary(string op, int RHSDim, RHST)(auto ref Vector!(RHSDim, RHST) rhs) const{
		alias typeof(T() * RHST()) ElType;
		alias typeof(rhs) RetType;

		static if(op == "*"){
			static assert(Columns == RHSDim, "Matrix and vector not able to be multiplied");
			RetType ret;

			foreach(i; 0..Rows){
				ElType sum = 0;

				foreach(k; 0..RHSDim){
					sum += get(k, i) * rhs.data[k];
				}
				
				ret.data[i] = sum; 
			}

			return ret;
		}else{
			static assert(0, "matrix-vector "~op~" operation not implemented");
		}
	}

	string toString() const {
		import std.string : format;

		string s = format("[%(%s, %)", data[0..Columns]);
		foreach(y; 1..Rows){
			s ~= format(",\n %(%s, %)", data[y*Columns .. (y+1)*Columns]);
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
	}else static if(Columns >= 3 && Rows >= 3){
		enum thisType identity = thisType(
			TupleRepeat!(max(Rows, Columns)-1, 1, TupleRepeat!(Columns, 0))[0..Columns*Rows]);
	}
}

alias Matrix!(2, 2) mat2;
alias Matrix!(3, 3) mat3;
alias Matrix!(4, 4) mat4;