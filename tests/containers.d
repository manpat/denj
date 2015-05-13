module tests.containers;

import denj.utility.log;
import denj.utility.containers;

void ContainerTests(){
	ForwardList!int fl;
	Log(fl);
	fl.Prepend(5);
	Log(fl);
	fl.Append(6);
	fl.Append(7);
	fl.Prepend(4);
	Log(fl, " length: ", fl.length);

	{
		int sum = 0;
		auto it = fl.begin;
		while(it){
			sum += it.value;
			it.Advance();
		}

		Log("Sum: ", sum);
	}

	{
		Log("Iterator modify");
		auto it = fl.begin.Advance();
		it.value = 10;
		Log(fl);
	}
}