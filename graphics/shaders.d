module denj.graphics.shaders;

import denj.graphics.common;
import denj.utility;
import denj.math;
import std.string;
import std.traits;
import std.regex;
import std.conv;

class ShaderProgram {
	public {
		uint glprogram = 0;
		int[string] uniformLocations;
	}

	this()(auto ref ShaderInfo info){
		glprogram = glCreateProgram();
		uint[] shaderUnits;

		foreach(ref u; info.units){
			auto unit = CompileUnit(info, u);
			glAttachShader(glprogram, unit);
			shaderUnits ~= unit;
		}

		glLinkProgram(glprogram);

		foreach(u; shaderUnits){
			glDeleteShader(u);
		}

		GLint status;
		glGetProgramiv(glprogram, GL_LINK_STATUS, &status);
		if(status == GL_FALSE){
			int logLength = 0;
			glGetProgramiv(glprogram, GL_INFO_LOG_LENGTH, &logLength);

			char[] buffer = new char[logLength];
			glGetProgramInfoLog(glprogram, logLength, null, buffer.ptr);

			Log(info.filename, ": ", buffer);
			throw new Exception("Program link fail");
		}

		foreach(u; info.data){
			if(u.type == ShaderData.Type.Uniform){
				uniformLocations[u.name.idup] = glGetUniformLocation(glprogram, u.name.toStringz);
			}
		}
	}

	uint CompileUnit()(ShaderInfo info, auto ref ShaderUnit unit){
		char[] src = "#version "~info.shaderVersion~'\n' ~ unit.src ~ '\0';
		auto srcp = src.ptr;

		uint glunit = glCreateShader(unit.stage);
		glShaderSource(glunit, 1, &srcp, null);
		glCompileShader(glunit);

		GLint status;
		glGetShaderiv(glunit, GL_COMPILE_STATUS, &status);
		if(status != GL_TRUE){
			char[] buffer = new char[1024];
			buffer[] = 0;
			glGetShaderInfoLog(glunit, 1024, null, buffer.ptr);

			enum lineNumberRegex = ctRegex!`[\d]+:([\d]+)\([\d]+\):`;
			char[] replaceFunc(Captures!(char[]) m){
				auto lineno = (m[1].to!int + unit.lineoffset).to!(char[]);

				char[] ret = lineno;
				if(info.filename.length > 0) 
					ret = info.filename ~ ":" ~ ret;

				return ret ~ ":";
			}

			buffer = replaceAll!replaceFunc(buffer, lineNumberRegex);

			Log(unit.stage);
			Log(buffer);
			throw new Exception("Shader compile fail");
		}

		return glunit;
	}

	static ShaderProgram LoadFromMemory(StringType)(StringType ssrc) {
		auto shaderInfo = ParseShaderFile(ssrc.to!(char[]));
		shaderInfo.filename = "<memory>".dup;

		return new ShaderProgram(shaderInfo);
	}

	static ShaderProgram LoadFromFile(StringType)(StringType filename) {
		import std.file;

		auto shaderInfo = ParseShaderFile(read(filename).to!(char[]));
		shaderInfo.filename = filename.to!(char[]);

		return new ShaderProgram(shaderInfo);
	}

	void SetUniform(T)(string s, T val){
		enum mangle = GetGLMangle!T;

		int pos = uniformLocations.get(s, -1);
		if(pos < 0) Log("Tried to set non existent uniform '", s, "'");

		static if(isVec!T){
			mixin("glUniform"~mangle~"v(pos, 1, val.data.ptr);");
		}else static if(isMat!T){
			mixin("glUniformMatrix"~mangle~"v(pos, 1, GL_TRUE, val.data.ptr);");
		}else{
			mixin("glUniform"~mangle~"(pos, val);");
		}
	}
}

/////////////////////////////////////////////////////////
//                                                     //
//  For internal use                                   //
//                                                     //
/////////////////////////////////////////////////////////


private struct ShaderUnit{
	enum Stage {
		Unknown,
		Vertex = GL_VERTEX_SHADER,
		TessControl = GL_TESS_CONTROL_SHADER,
		TessEval = GL_TESS_EVALUATION_SHADER,
		Geometry = GL_GEOMETRY_SHADER,
		Fragment = GL_FRAGMENT_SHADER,
		Compute = GL_COMPUTE_SHADER,
	}

	Stage stage;
	char[] src;
	uint lineoffset = 0;

	void SetStage(char[] ss){
		switch(ss){
			case "vertex": stage = Stage.Vertex; break;
			case "tesscontrol": stage = Stage.TessControl; break;
			case "tesseval": stage = Stage.TessEval; break;
			case "geometry": stage = Stage.Geometry; break;
			case "fragment": stage = Stage.Fragment; break;
			case "compute": stage = Stage.Compute; break;

			default: Log("Unknown shader stage '", ss, "'"); stage = Stage.Unknown; break;
		}
	}
}

private struct ShaderData {
	enum Type {
		Uniform,
		Attribute,
		Output,
	}

	Type type;
	char[] name;
	char[] dataType;
}

private struct ShaderInfo{
	char[] shaderVersion;
	char[] filename;
	ShaderUnit[] units;
	ShaderData[] data;
}

private ShaderInfo ParseShaderFile(char[] src){
	import std.algorithm : splitter;

	enum whitespaceRegex = ctRegex!`^\s*$`;
	enum preprocessRegex = ctRegex!`#(?P<type>\w+)\s+(?P<arg>\w+)`;

	// Will not handle all possible cases
	enum dataRegex = ctRegex!`(in|out|uniform)\s+(?P<type>\w+)\s+(?P<name>\w+)`;

	auto ret = ShaderInfo();
	ShaderUnit* unit = null;

	uint lineno = 0;
	foreach(line; splitter(src, '\n')){
		lineno++;
		if(matchFirst(line, whitespaceRegex)) {
			unit.src ~= '\n';
			continue;
		}

		auto preprocessMatch = matchFirst(line, preprocessRegex);
		if(preprocessMatch){
			switch(preprocessMatch["type"]){
				case "version":
					ret.shaderVersion = preprocessMatch["arg"];
					break;

				case "type":
					if(unit) {
						ret.units ~= *unit;
					}
					unit = new ShaderUnit();
					unit.lineoffset = lineno -1;
					unit.SetStage(preprocessMatch["arg"]);
					break;

				default:
					Log("Unknown preprocesser token '", preprocessMatch["type"], '\'');
			}
			continue;
		}

		// If a shader unit hasn't been specified, source doesn't make sense
		if(!unit || unit.stage == ShaderUnit.Stage.Unknown) continue;

		auto dataMatch = matchFirst(line, dataRegex);
		if(dataMatch){
			if(unit.stage == ShaderUnit.Stage.Vertex && dataMatch[1] == "in"){
				ret.data ~= ShaderData(ShaderData.Type.Attribute, dataMatch["name"], dataMatch["type"]);

			}else if(unit.stage == ShaderUnit.Stage.Fragment && dataMatch[1] == "out"){
				ret.data ~= ShaderData(ShaderData.Type.Output, dataMatch["name"], dataMatch["type"]);

			}else if(dataMatch[1] == "uniform"){
				ret.data ~= ShaderData(ShaderData.Type.Uniform, dataMatch["name"], dataMatch["type"]);
			}
		}

		unit.src ~= line ~ '\n';
	}

	if(unit) ret.units ~= *unit;

	return ret;
}