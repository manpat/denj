module denj.graphics.shaders;

import denj.graphics.common;
import denj.utility;
import std.string;
import std.conv;
import std.regex;

class ShaderProgram {
	private {
		uint glprogram = 0;
	}

	this()(auto ref ShaderInfo info){
		Log("ShaderProgram.this");

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
	}

	uint CompileUnit()(ShaderInfo info, auto ref ShaderUnit unit){
		Log("CompileUnit");
		char[] src = "#version "~info.shaderVersion~'\n' ~ unit.src ~ '\0';
		auto srcp = src.ptr;
		// Log(src);

		uint glunit = glCreateShader(unit.stage);
		glShaderSource(glunit, 1, &srcp, null);
		glCompileShader(glunit);

		GLint status;
		glGetShaderiv(glunit, GL_COMPILE_STATUS, &status);
		if(status == GL_FALSE){
			char[] buffer = new char[1024];
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
}

private struct ShaderUnit{
	enum Stage {
		Unknown,
		Vertex = GL_VERTEX_SHADER,
		Geometry = GL_GEOMETRY_SHADER,
		Fragment = GL_FRAGMENT_SHADER,
	}

	Stage stage;
	char[] src;
	uint lineoffset = 0;

	void SetStage(char[] ss){
		switch(ss){
			case "vertex": stage = Stage.Vertex; break;
			case "geometry": stage = Stage.Geometry; break;
			case "fragment": stage = Stage.Fragment; break;

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
	import std.algorithm;

	enum whitespaceRegex = ctRegex!`^\s*$`;
	enum preprocessRegex = ctRegex!`#(?P<type>\w+)\s+(?P<arg>\w+)`;

	// Will not handle all possible cases
	enum dataRegex = ctRegex!`(in|out|uniform)\s+(?P<type>\w+)\s+(?P<name>\w+)`;

	auto ret = ShaderInfo();
	ShaderUnit* unit = null;

	uint lineno = 0;
	foreach(line; splitter(src, '\n')){
		lineno++;
		if(matchFirst(line, whitespaceRegex)) continue;

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
					unit.lineoffset = lineno;
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