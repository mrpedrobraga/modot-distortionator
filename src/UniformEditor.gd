extends HBoxContainer
class_name UniformEditor

var layer #: Distortionator_LayerView
var d_core

var uniform
var editor
var sampler_file_dialog : FileDialog

signal changed(new_value)
signal uset(uniform_name, new_value)

func set_name(uniform_name : String):
	$lbl_uniform_name.text = uniform_name.capitalize()
	name = "u_" + uniform_name

func setup(uniform : Dictionary):
	self.uniform = uniform
	set_name(uniform.name)
	editor = get_node_or_null(uniform.type)
	if editor:
		editor.visible = true
	
	if not uniform.value:
		uniform.value = get_default_value(uniform.type)
	else:
		set_editor_value(uniform.value)
	
	
	sampler_file_dialog.connect("file_selected", self, "_on_file_picked")

func set_editor_value(value):
	match uniform.type:
		"bool":
			editor.pressed = value
		"float", "int":
			editor.value = value
		"vec2":
			editor.get_node("x").value = value.x
			editor.get_node("y").value = value.y
		"vec3":
			editor.get_node("x").value = value.x
			editor.get_node("y").value = value.y
			editor.get_node("z").value = value.z
		"vec4":
			editor.get_node("x").value = value.x
			editor.get_node("y").value = value.y
			editor.get_node("z").value = value.z
			editor.get_node("w").value = 0
		"sampler2D":
			if value is FileRef:
				editor.get_node("preview").texture = value.file
			else:
				editor.get_node("preview").texture = value
			print(value)

func set_value_no_signal(new_value, update_editor):
	uniform.value = new_value
	if update_editor:
		set_editor_value(new_value)

func set_value(new_value, update_editor = true):
	set_value_no_signal(new_value, update_editor)
	emit_signal("changed", uniform.value)
	emit_signal("uset", uniform.name, uniform.value)

func set_field_no_signal(field:String, new_value, update_editor):
	uniform.value[field] = new_value
	if update_editor:
		editor.get_node(field).value = uniform.value[field]

func set_field(field:String, new_value, update_editor = true):
	set_field_no_signal(field, new_value, update_editor)
	emit_signal("changed", uniform.value)
	emit_signal("uset", uniform.name, uniform.value)

func get_default_value(type : String):
	match type:
		"bool":
			return false
		"float":
			return 0.0
		"int":
			return 0
		"vec2":
			return Vector2()
		"vec3":
			return Vector3()
		"vec4":
			return Vector3()
		"sampler2D":
			return null

func _on_file_picked(path):
	if not sampler_file_dialog.get_meta("emitter") == self:
		return
	if path.get_extension() == "":
		return
	if not d_core.is_inside_godot_project(path):
		OS.alert("Resource must be inside the same godot project.")
		return
	var img = d_core.load_fileref(path)
	
	if not img:
		OS.alert("Invalid resource. Will remain unset.")
		return
	
	set_value(img)

func _on_bool_toggled(button_pressed):
	set_value(button_pressed)

func _on_int_value_changed(value):
	set_value(value)

func _on_float_value_changed(value):
	set_value(value)

func _on_x_value_changed(value):
	set_field("x", value)

func _on_y_value_changed(value):
	set_field("y", value)

func _on_z_value_changed(value):
	set_field("z", value)

func _on_w_value_changed(value):
	set_field("w", value)

func _on_btn_pick_new_file_pressed():
	sampler_file_dialog.set_meta("emitter", self)
	sampler_file_dialog.popup_centered(Vector2(500,400))
