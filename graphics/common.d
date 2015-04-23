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

	static if(is(T == Vector!(D, sT), int D, sT)){
		return min(max(D, 1), 4).to!string ~ GetGLBase!sT;
	}else{
		return "1"~GetGLBase!T;
	}
}