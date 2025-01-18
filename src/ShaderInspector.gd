extends Node
class_name ShaderInspector

const uniform_regex = "uniform\\s+(?<type>\\w+)\\s+(?<name>\\w+)\\s*(=\\s*(?<initial_value>.*))?"

static func get_uniform_list(shader_code : String) -> Dictionary:
	var r_uniform = RegEx.new()
	r_uniform.compile(uniform_regex)
	
	var result := {}
	
	for uniform_match in r_uniform.search_all(shader_code):
		var uniform := {}
		uniform.name = uniform_match.get_string("name")
		uniform.type = uniform_match.get_string("type")
		uniform.value = null
		
		if "initial_value" in uniform_match.names.keys():
			uniform.value = parse_value(uniform_match.get_string("initial_value"), uniform.type)
		
		result[uniform.name] = (uniform)
	
	return result

static func parse_value(val_string : String, type : String):
	match type:
		"bool":
			return val_string.strip_edges() == "true"
		"int":
			return val_string.to_int()
		"float":
			return val_string.to_float()
		"vec2":
			var r_vec2 = RegEx.new()
			r_vec2.compile("vec2\\s*\\((?<x>.*?)(?:\\s*,\\s*(?<y>.*?))\\)")
			var r_match : RegExMatch = r_vec2.search(val_string)
			
			if "y" in r_match.names.keys():
				return Vector2(r_match.get_string("x").to_float(), r_match.get_string("y").to_float())
			return Vector2(r_match.get_string("x").to_float(), r_match.get_string("x").to_float())
		"vec3":
			var r_vec3 = RegEx.new()
			r_vec3.compile("vec3\\s*\\((?<x>.*?)(?:\\s*,\\s*(?<y>.*?)\\s*,\\s*(?<y>.*?))\\)")
			var r_match : RegExMatch = r_vec3.search(val_string)
			
			if "y" in r_match.names.keys():
				return Vector3(r_match.get_string("x").to_float(), r_match.get_string("y").to_float(), r_match.get_string("z").to_float())
			return Vector3(r_match.get_string("x").to_float(), r_match.get_string("x").to_float(), r_match.get_string("x").to_float())
		"vec4":
			var r_vec4 = RegEx.new()
			r_vec4.compile("vec4\\s*\\((?<x>.*?)(?:\\s*,\\s*(?<y>.*?)\\s*,\\s*(?<y>.*?)\\s*,\\s*(?<y>.*?))\\)")
			var r_match : RegExMatch = r_vec4.search(val_string)
			
			if "y" in r_match.names.keys():
				return Vector3(r_match.get_string("x").to_float(), r_match.get_string("y").to_float(), r_match.get_string("z").to_float())
			return Vector3(r_match.get_string("x").to_float(), r_match.get_string("x").to_float(), r_match.get_string("x").to_float())
		_:
			return null
