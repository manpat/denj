module tests.entities;

import denj.utility;
import denj.scene;
import std.string;

void EntityTests(){
	Log("New scene");
	auto s = new Scene();

	Log("New entity");
	auto e1 = s.NewEntity();
	Log(e1.id);

	Log("Adding component");
	e1.AddComponent!TestComponent(123f);
	e1.AddComponent!TestComponent();
	e1.AddComponent!BlahComponent();

	Log(e1.components);

	Log(__traits(allMembers, TestComponent));
	Log(__traits(allMembers, BlahComponent));

	Log("Destroy entity");
	s.DestroyEntity(e1);

	auto e2 = s.NewEntity();
	Log(e2 == e1);
	Log(e2.components);
}

class TestComponent : Component{
	float data;

	this(float _data = 0f){
		data = _data;
	}

	override string toString() const {
		return "Test(%f)".format(data);
	}
}

class BlahComponent : Component{
	override void OnUpdate(){

	}

	override string toString() const {
		return "Blah()";
	}
}