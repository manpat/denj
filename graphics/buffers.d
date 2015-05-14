module denj.graphics.buffers;

import denj.graphics.errorchecking;
import denj.graphics.common;
import denj.utility;
import denj.math;

private __gshared {
	Buffer[BufferType] boundBuffers;
}

// TODO: move all this shit back into Buffer
enum BufferType {
	Array = GL_ARRAY_BUFFER,
	Index = GL_ELEMENT_ARRAY_BUFFER,
	Uniform = GL_UNIFORM_BUFFER,
	ShaderStorage = GL_SHADER_STORAGE_BUFFER,
} 
enum BufferUsage {
	StaticDraw = GL_STATIC_DRAW,
	StaticRead = GL_STATIC_READ,
	StaticCopy = GL_STATIC_COPY,
	StreamDraw = GL_STREAM_DRAW,
	StreamRead = GL_STREAM_READ,
	StreamCopy = GL_STREAM_COPY,
	DynamicDraw = GL_DYNAMIC_DRAW,
	DynamicRead = GL_DYNAMIC_READ,
	DynamicCopy = GL_DYNAMIC_COPY,
}

template isBuffer(T){
	enum isBuffer = is(T == Buffer);
}

bool IsBufferBound(BufferType t){
	return boundBuffers.get(t, null) !is null;
}

Buffer GetBoundBuffer(BufferType t){
	return boundBuffers.get(t, null);
}

class Buffer {
	public { // TODO: Make private
		GLuint glbuffer;
		BufferType type;
		BufferUsage usage;
		size_t count;
		GLuint basegltype;
		uint typeelements;
		size_t elementsize;
	}

	this(BufferType _type = BufferType.Array, BufferUsage _usage = BufferUsage.StaticDraw){
		cgl!glGenBuffers(1, &glbuffer);
		if(!glbuffer) "Buffer creation failed".Except;

		type = _type;
		usage = _usage;
		basegltype = 0;
		count = 0;
		typeelements = 0;
		elementsize = 0;
	}

	~this(){
		cgl!glDeleteBuffers(1, &glbuffer);
		glbuffer = 0;
	}

	@property {
		size_t length(){
			return count;
		}

		uint elements(){
			return typeelements;
		}

		uint glBaseType(){
			return basegltype;
		}
	}

	void Upload(T)(T[] data){
		auto bb = boundBuffers.get(type, null);
		if(bb != this) cgl!glBindBuffer(type, glbuffer);

		if(data.length == count && T.sizeof == elementsize){
			// Don't reallocate buffer, just update
			cgl!glBufferSubData(type, 0, count*T.sizeof, data.ptr);
		}else{
			cgl!glBufferData(type, data.length*T.sizeof, data.ptr, usage);
			count = data.length;
		}

		elementsize = T.sizeof;
		static if(isVec!T){
			basegltype = GetGLType!(T.BaseType);
			typeelements = T.Dimensions;

		}else static if(__traits(isScalar, T)){
			basegltype = GetGLType!T;
			typeelements = 1;

		}else{
			static assert(0, "Can't do it");
		}

		if(bb && bb != this) cgl!glBindBuffer(type, bb.glbuffer);
	}

	void Bind(){
		cgl!glBindBuffer(type, glbuffer);
		boundBuffers[type] = this;
	}

	void Unbind(){
		if(boundBuffers.get(type, null) == this){
			cgl!glBindBuffer(type, 0);
			boundBuffers[type] = null;
		}
	}

	// Needs to be bound first
	void AllocateStorage(T = ubyte)(size_t _size){
		// Make sure size is within bounds set by opengl
		cgl!glBufferData(type, _size*T.sizeof, null, usage);
		count = _size;
		elementsize = T.sizeof;

		static if(isVec!T){
			basegltype = GetGLType!(T.BaseType);
			typeelements = T.Dimensions;

		}else static if(__traits(isScalar, T)){
			basegltype = GetGLType!T;
			typeelements = 1;

		}else{
			static assert(0, "Can't do it");
		}
	}

	T[] Map(T)(){
		// This mapping is super naïve
		return (cast(T*) cgl!glMapBufferRange(type, 0, count*elementsize,
					GL_MAP_READ_BIT|GL_MAP_WRITE_BIT))[0..count];
	}

	void Unmap(){
		cgl!glUnmapBuffer(type);	
	}
}