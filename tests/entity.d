module tests.entities;

import denj.utility;
import denj.scene;
import denj.math;
import std.string;

void EntityTests(){
	Log("=== New scene ===");
	auto s = new Scene();

	Log("\n=== New entity ===");
	auto e1 = s.NewEntity();
	Log("Entity ID: ", e1.id);

	Log("\n=== Adding components ===");
	e1.AddComponent!TestComponent(123f);
	auto tc = e1.AddComponent!TestComponent();
	e1.AddComponent!BlahComponent();
	e1.AddComponent!DummyComponent();
	e1.AddComponent!DummyComponent();

	tc.data = 3.14159f;
	Log(e1.components);

	Log("TestComponent: ", e1.FindComponent!TestComponent());

	Log("\n=== RemoveComponent components ===");
	e1.RemoveComponent(tc);
	e1.RemoveComponents!DummyComponent();
	Log(e1.components);

	Log("Entity has TestComponent: ", e1.HasComponent!TestComponent);
	Log("Entity has DummyComponent: ", e1.HasComponent!DummyComponent);

	Log("\n=== Adding children ===");
	auto echild = s.NewEntity();
	e1.AddChild(echild);

	Log("\n=== Updating scene ===");
	s.UpdateEntities();
	tc.active = false;
	s.UpdateEntities();

	auto e3 = s.NewEntity();
	foreach(i; 0..24) s.NewEntity();
	auto e4 = s.NewEntity();

	void LogEPool(){
		Log("Entity Pool:");
		foreach(ref e; s.entityPool){
			LogF("\t%2s (%s||%s) alive: %s", e.id, &e, e.reference.value, e.isAlive);
		}
	}

	LogEPool();
	Log("\n=== Destroy entity ===");
	s.DestroyEntity(e1);
	LogEPool();
	
	Log("Unshuffled entity: (", e3.value, ")"); // Just to make sure that the reference is still valid
	Log("Shuffled entity:   (", e4.value, ")"); // Just to make sure that the reference is still valid

	Log("\n=== New Entity ===");
	auto e2 = s.NewEntity();
	Log("E1 == E2?\t", e2 == e1);
	Log("E1 =\t", e1.value);
	Log("E2 =\t", *e2.value);
	Log("E2.components: ", e2.components);
	LogEPool();
}

class DummyComponent : Component{
	override string toString() const {
		return typeString;
	}	
}

class TestComponent : Component{
	float data;

	this(float _data = 0f){
		data = _data;
	}

	override void OnUpdate(){
		Log("Test update ", data);
	}

	override void OnDestroy(){
		Log("Test destroy ", data, "\tactive? ", active);
	}

	override string toString() const {
		return "Test(%f)".format(data);
	}
}

class BlahComponent : Component, RenderableComponent{
	override void OnUpdate(){
		Log("Blah update");
	}

	override void OnRender(){
		Log("Blah render");
	}

	override void OnDestroy(){
		Log("Blah destroy");
	}

	override string toString() const {
		return "Blah()";
	}
}