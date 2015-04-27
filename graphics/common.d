module denj.graphics.common;

public{
	import derelict.opengl3.gl3;
}

string GetGLMangle(T)(){
	import std.algorithm;
	import std.traits;
	import std.conv;
	import denj.math;

	template GetGLBase(sT){
		static if(isFloatingPoint!sT){
			enum GetGLBase = "f";
		}else static if(isBoolean!sT){
			enum GetGLBase = "b";
		}else static if(isIntegral!sT){
			enum GetGLBase = (isUnsigned!sT)?"ui":"i";
		}else{
			enum GetGLBase = "";
		}
	}

	static if(isVec!T){
		static if(clamp(T.Dimensions, 1, 4) == T.Dimensions){
			return clamp(T.Dimensions, 1, 4).to!string ~ GetGLBase!(T.BaseType);
		}else{
			static assert(0, "GLMangle of Vector!" ~ T.Dimensions.to!string ~ " not supported");
		}

	}else static if(isMat!T){
		enum C = T.Columns;
		enum R = T.Rows;

		static if(C == R && C >= 2 && C <= 4){
			return C.to!string ~ GetGLBase!(T.BaseType);
		}else static if(clamp(C, 2, 4) == C && clamp(R, 2, 4) == R){
			return C.to!string ~ "x" ~ R.to!string ~ GetGLBase!(T.BaseType);
		}else{
			static assert(0, "GLMangle of Matrix(" ~ C.to!string ~ ", " ~ R.to!string ~ ") not supported");
		}

	}else{
		return "1"~GetGLBase!T;
	}
}

template GetGLType(T){
	import std.traits;
	
	static if(isFloatingPoint!T){
		enum GetGLType = GL_FLOAT;
	}else static if(isBoolean!T){
		enum GetGLType = GL_BOOL;
	}else static if(isIntegral!T){
		static if(T.sizeof == 1){
			enum Base = "BYTE";
		}else static if(T.sizeof == 2) {
			enum Base = "SHORT";
		}else static if(T.sizeof == 4) {
			enum Base = "INT";
		}else{
			static assert(0, "GetGLType failed for type " ~ T.stringof);
		}

		static if(isUnsigned!T){
			enum GetGLType = mixin("GL_UNSIGNED_"~Base);
		}else{
			enum GetGLType = mixin("GL_"~Base);
		}
	}else{
		static assert(0, "Can't convert "  ~ T.stringof ~ " to GL type enum");
	}
}