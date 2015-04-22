module denj.graphics.shaders;

import denj.graphics.common;
import denj.utility;
import std.string;
import std.conv;
import std.regex;

class ShaderProgram {

	static ShaderProgram LoadFromMemory(StringType)(StringType ssrc) {
		auto shaderData = ParseShaderFile(ssrc.to!(char[]));
		Log(shaderData);

		return null;
	}
}

private struct ShaderUnit{
	char[] stage;
	char[] src;
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

	foreach(line; splitter(src, '\n')){
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
					unit.stage = preprocessMatch["arg"];
					break;

				default:
					Log("Unknown preprocesser token '", preprocessMatch["type"], '\'');
			}
			continue;
		}

		// If a shader unit hasn't been specified, source doesn't make sense
		if(!unit || unit.stage == "") continue;

		auto dataMatch = matchFirst(line, dataRegex);
		if(dataMatch){
			if(unit.stage == "vertex" && dataMatch[1] == "in"){
				ret.data ~= ShaderData(ShaderData.Type.Attribute, dataMatch["name"], dataMatch["type"]);

			}else if(unit.stage == "fragment" && dataMatch[1] == "out"){
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