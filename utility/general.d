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

template TupleRepeat(int Count, T...){
	static if(Count <= 1){
		alias TupleRepeat = T;
	}else{
		alias TupleRepeat = Tuple!(T, TupleRepeat!(Count-1, T));
	}
}

template Compare(A...){
	static if(__traits(isSame, A[0], A[1])){ // Same name?
		enum Compare = true;
	}else static if(is(A[0]) && is(A[1]) && is(A[0] == A[1])){ // Types are same
		enum Compare = true;
	}else static if(!is(A[0]) && !is(A[1]) && is(typeof(A[0]) == typeof(A[1])) && A[0] == A[1]){ // Values are same
		enum Compare = true;
	}else{
		enum Compare = false;
	}
}

template TupleContains(T...){
	static if(T.length == 1){
		enum TupleContains = false;
	}else static if(Compare!(T[0], T[1])){
		enum TupleContains = true;
	}else{
		enum TupleContains = TupleContains!(T[0], T[2..$]);
	}
}
template TupleRemove(T...){
	static if(T.length == 1){
		alias TupleRemove = Tuple!();
	}else static if(Compare!(T[0], T[1])){
		alias TupleRemove = TupleRemove!(T[0], T[2..$]);
	}else{
		alias TupleRemove = Tuple!(T[1], TupleRemove!(T[0], T[2..$]));
	}
}

void Except(size_t line = __LINE__, string file = __FILE__)(string s){
	throw new Exception(s, file, line);
}