module denj.scene.scene;

import denj.utility;
import denj.utility.sharedreference;
import denj.scene.entity;
import std.algorithm;

class Scene {
	SharedReference!Entity[] entities;
	size_t lastEntityID = 0;

	this(){
		entities.length = 32;
		foreach(ref e; entities){
			e = SharedReference!Entity(new Entity());
		}
	}

	SharedReference!Entity NewEntity(){
		auto e = _FindUnusedEntity();
		if(!e){
			Log("No free entity");
			entities.length = entities.capacity*2;
			// TODO: Construct new Entities

			e = _FindUnusedEntity();
			if(!e) "Scene unable to create new entities".Except;
		}
		e.Init();
		e.id = ++lastEntityID;

		return e;
	}

	void DestroyEntity(SharedReference!Entity e){
		e.Destroy();
	}

private:
	SharedReference!Entity _FindUnusedEntity(){
		Log("Finding unused entity...");
		if(any!"!a"(entities)) "Null entity in scene list".Except; 

		auto es = find!"!a.isAlive"(entities);
		if(es.length > 0) return es[0];
		return SharedReference!Entity();
	}
}
