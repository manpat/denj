module tests.containers;

import denj.utility.log;
import denj.utility.containers;

void ContainerTests(){
	ForwardList!int fl;
	Log(fl);
	fl.Prepend(5);
	Log(fl);
	fl.Append(6);
	fl.Append(7).Prepend(4);
	Log(fl, " length: ", fl.length);

	{
		int sum = 0;
		fl.ConstIterator it = fl.cbegin;
		while(it){
			sum += it.value;
			it.Advance();
		}

		Log("Sum: ", sum);
	}

	{
		Log("Iterator modify");
		auto it = fl.begin.Advance().Advance(2);
		it.value = 10;
		Log(fl);
	}
}