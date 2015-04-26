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