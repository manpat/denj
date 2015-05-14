module denj.utility.sharedreference;

struct SharedReference(T){
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
		return data.object;
	}
}