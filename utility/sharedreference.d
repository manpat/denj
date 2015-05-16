module denj.utility.sharedreference;

struct SharedReference(T){
	// Probably doesn't need to be a struct, but
	//	I made it one just in case it ever needs extra
	//	data. + memory representation is identical
	private static struct SharedData {
		T* object;
	}

	SharedData* data = null;

	this(T* o){
		data = new SharedData(o);
	}

	this(SharedReference!T o){
		data = o.data;
	}

	alias value this;
	@property T* value(){
		return data?data.object:null;
	}

	// To be called if object is moved
	void SetReference(T* o){
		if(data){
			data.object = o;
		}else{
			data = new SharedData(o);
		}
	}

	void InvalidateReference(){
		// Don't try to invalidate the reference if it 
		//	hasn't been initialised	
		if(data){
			data.object = null;
		}
	}
}