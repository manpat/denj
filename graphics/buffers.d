module denj.graphics.buffers;

import denj.graphics.errorchecking;
import denj.graphics.common;
import denj.utility;
import denj.math;

private __gshared {
	uint[BufferType] boundBuffers;
}

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
	static if(is(T == Buffer!sT, sT)){
		enum isBuffer = true;
	}else{
		enum isBuffer = false;
	}
}

class Buffer(T) {
	alias BaseType = T;

	private {
		GLuint glbuffer;
		BufferType type;
		BufferUsage usage;
		size_t size;
	}

	this(BufferType _type = BufferType.Array, BufferUsage _usage = BufferUsage.StaticDraw){
		cgl!glGenBuffers(1, &glbuffer);
		if(!glbuffer) throw new Exception("Buffer creation failed");

		type = _type;
		usage = _usage;
		size = 0;
	}

	~this(){
		cgl!glDeleteBuffers(1, &glbuffer);
		glbuffer = 0;
	}

	@property {
		size_t length(){
			return size;
		}

		uint elements(){
			static if(isVec!T){
				return T.Dimensions;
			}else static if(isMat!T){
				assert(0, "element counts for Matrix buffers not supported");
				return 1;
			}else{ // scalar
				return 1;
			}
		}
	}

	void Upload(T[] data){
		auto bb = boundBuffers.get(type, 0);
		if(bb != glbuffer) cgl!glBindBuffer(type, glbuffer);

		if(data.length == size){
			// Don't reallocate buffer, just update
			cgl!glBufferSubData(type, 0, size*T.sizeof, data.ptr);
		}else{
			cgl!glBufferData(type, data.length*T.sizeof, data.ptr, usage);
			size = data.length;
		}

		if(bb != glbuffer) cgl!glBindBuffer(type, bb);
	}

	void Bind(){
		cgl!glBindBuffer(type, glbuffer);
		boundBuffers[type] = glbuffer;
	}

	void Unbind(){
		if(boundBuffers.get(type, 0) == glbuffer){
			cgl!glBindBuffer(type, 0);
			boundBuffers[type] = 0;
		}
	}

	// Needs to be bound first
	void AllocateStorage(size_t _size){
		// Make sure size is within bounds set by opengl
		cgl!glBufferData(type, _size*T.sizeof, null, usage);
		size = _size;
	}

	T* Map(){
		// This mapping is super naïve
		return cast(T*) cgl!glMapBufferRange(type, 0, size*T.sizeof,
			GL_MAP_READ_BIT|GL_MAP_WRITE_BIT);
	}

	void Unmap(){
		cgl!glUnmapBuffer(type);	
	}
}