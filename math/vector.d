module denj.math.vector;

public import std.math;
import std.string : format;

template isVec(T){
	enum isVec = is(T == Vector!(D, sT), int D, sT);
}

struct Vector(int Dim, T = float){
	alias Vector!(Dim, T) thisType;
	enum Dimensions = Dim;
	alias BaseType = T;

	public {
		T[Dim] data;

		@property ref T get(int i)(){
			return data[i];
		}
	}

	alias get!0 x;
	alias get!0 r;
	alias get!0 s;
	alias get!0 u;

	static if(Dim >= 2){
		alias get!1 y;
		alias get!1 g;
		alias get!1 t;
		alias get!1 v;
	}
	static if(Dim >= 3){
		alias get!2 z;
		alias get!2 b;
		alias get!2 p;
	}
	static if(Dim >= 4){
		alias get!3 w;
		alias get!3 a;
		alias get!3 q;
	}

	this(T _data){
		data[] = _data;
	}
	this(T[Dim] _data){
		data[] = _data[];
	}
	this(T[Dim] _data...){
		data[] = _data[];
	}

	T magnitude(){
		return sqrt(magnitude_sqr);
	}
	T magnitude_sqr(){
		T sum = data[0];
		for(uint i = 1; i < Dim; i++){
			sum += data[i] * data[i];
		}
		return sum;
	}

	thisType normalised(){
		thisType ret = this;
		auto mag = magnitude;
		if(mag == 0.0) return zero;
		return ret/mag;
	}

	T dot()(const auto ref thisType rhs){
		T sum = 0.0;
		for(uint i = 0; i < Dim; i++){
			sum += data[i] * rhs.data[i];
		}
		return sum;
	}

	thisType cross()(const auto ref thisType rhs) if(Dim == 3){
		thisType ret;

		ret.x = data[1]*rhs.data[2] - data[2]*rhs.data[1];
		ret.y = data[2]*rhs.data[0] - data[0]*rhs.data[2];
		ret.z = data[0]*rhs.data[1] - data[1]*rhs.data[0];

		return ret;
	}

	thisType opUnary(string s)() if(s == "-"){
		thisType ret = this;
		ret.data[] = -ret.data[];
		return ret;
	}

	thisType opBinary(string s)(const auto ref thisType rhs){
		thisType ret;
		mixin("ret.data[] = data[] " ~ s ~ " rhs.data[];");
		return ret;
	}
	thisType opBinary(string s)(T rhs){
		thisType ret;
		mixin("ret.data[] = data[] " ~ s ~ " rhs;");
		return ret;
	}

	private void swizzleCompose(string s, int idx = 0, int size = 0)(ref T[size] ret) const{
		import std.string : indexOfAny;

		static if(s.length > 0){
			static if([s[0]].indexOfAny("xrsu") != -1){
				ret[idx] = data[0];
			}else static if([s[0]].indexOfAny("ygtv") != -1){
				ret[idx] = data[1];
			}else static if([s[0]].indexOfAny("zbp") != -1){
				ret[idx] = data[2];
			}else static if([s[0]].indexOfAny("waq") != -1){
				ret[idx] = data[3];
			}

			swizzleCompose!(s[1..$], idx+1, size)(ret);
		}
	}
	private void swizzleAssign(string s, int idx = 0, int size = 0)(ref T[size] rhs){
		import std.string : indexOfAny;

		static if(s.length > 0){
			static if([s[0]].indexOfAny("xrsu") != -1){
				data[0] = rhs[idx];
			}else static if([s[0]].indexOfAny("ygtv") != -1){
				data[1] = rhs[idx];
			}else static if([s[0]].indexOfAny("zbp") != -1){
				data[2] = rhs[idx];
			}else static if([s[0]].indexOfAny("waq") != -1){
				data[3] = rhs[idx];
			}

			swizzleAssign!(s[1..$], idx+1, size)(rhs);
		}
	}

	@property{
		auto opDispatch(string s, Assign...)(Assign ass) {
			static if(Assign.length == 0){
				auto ret = Vector!(s.length, T)();
				swizzleCompose!(s, 0, s.length)(ret.data);

				return ret;

			}else static if(is(Assign[0] : Vector!(s.length, T))){
				static assert(s.length < Dim, "Swizzle assign cannot assign more members than exists");
				swizzleAssign!(s, 0, s.length)(ass[0].data);

				return this;
			}
		}
	} 

	string toString() const {
		static if(Dim == 2){
			return format("(%s, %s)", data[0], data[1]);
		}else static if(Dim == 3){
			return format("(%s, %s, %s)", data[0], data[1], data[2]);
		}else static if(Dim == 4){
			return format("(%s, %s, %s, %s)", data[0], data[1], data[2], data[3]);

		}else static if(Dim > 4){
			import std.conv : to;

			string s = "(";
			foreach(d; data[0..$-1]){
				s ~= to!string(d) ~ ", ";
			}
			s ~= to!string(data[$-1]) ~ ")";

			return s;
		}else{
			static assert(0, format("Vector%s%s.toString not implemented", Dim, T.mangleof));
		}
	}

	static if(Dim == 2){
		enum thisType up = thisType(0, 1);
		enum thisType right = thisType(1, 0);
	}else static if(Dim == 3){
		enum thisType up = thisType(0, 1, 0);
		enum thisType right = thisType(1, 0, 0);
		enum thisType forward = thisType(0, 0, 1);
	}else static if(Dim == 4){
		enum thisType up = thisType(0, 1, 0, 0);
		enum thisType right = thisType(1, 0, 0, 0);
		enum thisType forward = thisType(0, 0, 1, 0);
	}
	enum thisType zero = thisType(0);
	enum thisType one = thisType(1);
}

alias Vector!2 vec2;
alias Vector!3 vec3;
alias Vector!4 vec4;

alias Vector!(2, double) dvec2;
alias Vector!(3, double) dvec3;
alias Vector!(4, double) dvec4;