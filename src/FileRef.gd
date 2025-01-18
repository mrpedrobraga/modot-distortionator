extends Resource
class_name FileRef

export var project_path : String = "res://"
export var abs_path : String = "res://file.png"
var file
var is_default : bool = false

static func create(project_path_:String, content, abs_path_ : String, is_default_:bool=false):
	var self_class = load("res://src/FileRef.gd")
	var fr = self_class.new()
	fr.project_path = project_path_
	fr.abs_path = abs_path_
	fr.file = content
	fr.is_default = is_default_
	
	return fr

func get_rel_path():
	project_path = project_path.simplify_path()
	abs_path = abs_path.simplify_path()
	if not project_path.is_subsequence_of(abs_path):
		return null
	var rel_path = abs_path.replace(project_path, "").simplify_path()
	return rel_path
