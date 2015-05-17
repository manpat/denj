module denj.scene.scene;

import denj.utility;
import denj.utility.sharedreference;
import denj.scene.entity;
import std.algorithm;

class Scene {
	Entity[] entityPool;
	size_t lastEntityID = 0;
	size_t numAliveEntities = 0;

	this(){
		entityPool.length = 8;
	}

	SharedReference!Entity NewEntity(){
		auto e = FindUnusedEntity();
		if(!e){
			Log("No free entity");
			entityPool.length = entityPool.capacity*2;

			// TODO: Fuck this off
			size_t end = entityPool.length/2;
			while(!entityPool[end].isAlive){
				end--;
			}

			foreach(ref ent; entityPool[0..end+1]){
				ent.reference.SetReference(&ent);
			}

			e = FindUnusedEntity();
			if(!e) "Scene unable to create new entities".Except;
		}
		e.Init();
		e.id = ++lastEntityID;
		e.owningScene = this;

		numAliveEntities++;

		e.reference = SharedReference!Entity(e);
		return e.reference;
	}

	void DestroyEntity(SharedReference!Entity e){
		// If reference is valid, notify the entity and
		//	shuffle it so that alive entities get queried
		//	and updated before dead ones
		if(e) {
			e.Destroy();
			BubbleEntity(e.value); 
		}
		e.InvalidateReference();

		numAliveEntities--;
	}

	void UpdateEntities(){
		foreach(ref e; entityPool[0..numAliveEntities]){
			e.Update();
		}
	}

private:
	Entity* FindUnusedEntity(){
		Log("Finding unused entity...");

		auto es = find!"!a.isAlive"(entityPool);
		if(es.length > 0) {
			Log("Found ", &es[0]);
			return &es[0];
		}
		return null;
	}

	// Swaps a dead entity with an alive entity at the end of the pool
	//	Calling this with each entity that dies will ensure that entities
	//	toward the beginning of the pool are always alive
	void BubbleEntity(Entity* deadIt){
		import std.algorithm : swap;

		auto aliveIt = &entityPool[$-1];

		// Search for an alive entity at the end of the pool
		while(aliveIt != deadIt && !aliveIt.isAlive){
			aliveIt--;
		}

		// If one was found, swap
		if(aliveIt != deadIt){
			// Log("Swap dead ", deadIt, " with alive ", aliveIt);
			// Log("Swap dead ", deadIt.id, " with alive ", aliveIt.id);
			
			// Log("Alive: ", aliveIt.reference.value());
			// Log("Dead: ", 	deadIt.reference.value());

			aliveIt.reference.SetReference(deadIt);
			swap(*deadIt, *aliveIt);
			// Dead reference doesn't need to be set as it's set
			//	upon entity creation
		}
	}
}
