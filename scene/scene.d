module denj.scene.scene;

import denj.utility;
import denj.utility.sharedreference;
import denj.scene.entity;
import std.algorithm;

class Scene {
	Entity[] entityPool;
	size_t lastEntityID = 0;

	this(){
		entityPool.length = 8;
	}

	SharedReference!Entity NewEntity(){
		auto e = FindUnusedEntity();
		if(!e){
			Log("No free entity");
			entityPool.length = entityPool.capacity*2;

			e = FindUnusedEntity();
			if(!e) "Scene unable to create new entities".Except;
		}
		e.Init();
		e.id = ++lastEntityID;
		e.owningScene = this;

		e.reference = SharedReference!Entity(e);
		return e.reference;
	}

	void DestroyEntity(SharedReference!Entity e){
		// If reference is valid, notify the entity and
		//	shuffle it so that alive entities get queried
		//	and updated before dead ones
		if(e) {
			e.Destroy();

			// This will be slow if you're trying to delete a bunch of things
			//	so maybe find a way to move this somewhere else
			BubbleEntity(e.value); 
		}
		e.InvalidateReference();
	}

	// TODO: Make better
	void UpdateEntities(){
		foreach(ref e; entityPool){
			if(e.isAlive && e.isActive){
				e.Update();
			}
		}
	}

private:
	Entity* FindUnusedEntity(){
		Log("Finding unused entity...");

		auto es = find!"!a.isAlive"(entityPool);
		if(es.length > 0) return &es[0];
		return null;
	}

	void BubbleEntity(Entity* deadIt){
		import std.algorithm : swap;

		auto aliveIt = &entityPool[$-1];

		// Search for an alive entity at the end of the pool
		while(aliveIt != deadIt && !aliveIt.isAlive){
			aliveIt--;
		}

		// If one was found, swap
		if(aliveIt != deadIt){
			// Log("Swap dead ", deadIt.id, " with alive ", aliveIt.id);
			
			swap(*deadIt, *aliveIt);
			aliveIt.reference.SetReference(aliveIt);
			// Dead reference doesn't need to be set as it's set
			//	upon entity creation
		}
	}
}
