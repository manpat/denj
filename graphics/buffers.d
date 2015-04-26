module denj.graphics.buffers;

import denj.graphics.common;
import denj.utility;

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

class Buffer(T) {
	public { // Change to private
		GLuint glbuffer;
		BufferType type;
		BufferUsage usage;
		size_t size;
	}

	this(BufferType _type = BufferType.Array, BufferUsage _usage = BufferUsage.StaticDraw){
		glGenBuffers(1, &glbuffer);
		if(!glbuffer) throw new Exception("Buffer creation failed");

		type = _type;
		size = 0;
	}

	~this(){
		glDeleteBuffers(1, &glbuffer);
		glbuffer = 0;
	}

	@property {
		size_t length(){
			return size;
		}
	}

	void Upload(T[] data){
		auto bb = boundBuffers.get(type, 0);
		glBindBuffer(type, glbuffer);

		if(data.length == size){
			// Don't reallocate buffer, just update
			glBufferSubData(type, 0, size*T.sizeof, data.ptr);
		}else{
			glBufferData(type, data.length*T.sizeof, data.ptr, usage);
			size = data.length;
		}

		glBindBuffer(type, bb);
	}

	void Bind(){
		glBindBuffer(type, glbuffer);
		boundBuffers[type] = glbuffer;
	}

	void Unbind(){
		if(boundBuffers.get(type, 0) == glbuffer){
			glBindBuffer(type, 0);
			boundBuffers[type] = 0;
		}
	}

	T* Map(){
		return null;
	}

	void Unmap(){

	}
}