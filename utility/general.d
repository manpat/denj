module denj.utility.general;

import std.conv;

template Tuple(T...){
	alias Tuple = T;
}

string TupleToString(T...)(T t){
	static if(T.length > 1){
		return to!string(t[0]) ~ TupleToString(t[1..$]);
	}else static if(T.length == 1){
		return to!string(t[0]);
	}
}

// Tuple search
// Tuple remove

void Except(size_t line = __LINE__, string file = __FILE__)(string s){
	throw new Exception(s, file, line);
}