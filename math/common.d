module denj.math.common;

import std.math;
public import std.algorithm : min, max;

T clamp(T)(T val, T lb, T ub){
	return min(max(val, lb), ub);
}