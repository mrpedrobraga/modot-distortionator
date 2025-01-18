extends Node
class_name Distortionator_Core

#-- THE UI --#

## The containers

onready var new_panel : Control = $"new_panel"
onready var main_edit_panel : Control = $"p"

onready var project_file_dialog : FileDialog = $"ProjectFileDialog"
onready var sampler_file_dialog : FileDialog = $"ImageDialog"

onready var shader_edit_panel : VBoxContainer = $"p/v/HSplit/ShaderEditPanel"
onready var shaders_container : TabContainer = $"p/v/HSplit/ShaderEditPanel/TabContainer"

onready var layers_viewport : Viewport = $"p/Viewport"
onready var layers_gif_recorder : GifRecorder = $"p/Viewport/GifRecorder"
onready var layers_container : Control = $"p/Viewport/LayerContainer"
onready var layers_list : ItemList = $"p/v/HSplit/PropertyEditPanel/dock_proj_layers/Layers/layer_list"

onready var parameter_dock : Control = $"p/v/HSplit/PropertyEditPanel/dock_properties/Parameters"
onready var layer_property_editors_container : Control = $"p/v/HSplit/PropertyEditPanel/dock_properties/Parameters/layer_properties"
onready var uniform_editors_container : Control = $"p/v/HSplit/PropertyEditPanel/dock_properties/Parameters/uniforms/uniform_editors"

## The resources

const play_icon = preload("res://assets/icons/Play.png")
const pause_icon = preload("res://assets/icons/Pause.png")
const layer_view_scene = preload("res://scenes/LayerView.tscn")
const shader_editor_scene = preload("res://scenes/ShaderEditor.tscn")
const uniform_editor_scene = preload("res://scenes/UniformEditor.tscn")
const property_editor_scene = preload("res://scenes/PropertyPicker.tscn")

func _ready():
	setup_ui()
	import_settings()

func setup_ui():
	#$"p/v/HSplit/ShaderEditPanel/TabContainer/Default".text = preload("res://assets/default_shader.tres").code
	pass

func import_settings():
	var settings

func btn_file_id_pressed(id : int):
	match id:
		0: # NEW
			pass
		1: # OPEN...
			pass
		2: # SAVE
			pass
		3: # SAVE AS...
			pass

func btn_project_id_pressed(id : int):
	match id:
		0: # IMPORT...
			pass
		1: # EXPORT...
			pass

var project_file_dialog_mode := "New Project"

func _on_btn_project_new_pressed():
	project_file_dialog_mode = "New Project"
	project_file_dialog.mode = FileDialog.MODE_SAVE_FILE
	project_file_dialog.popup_centered(Vector2(500, 600))

func _on_btn_project_open_pressed():
	project_file_dialog_mode = "Open Project"
	project_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	project_file_dialog.popup_centered(Vector2(500, 600))

func _on_btn_project_close_pressed():
	new_panel.visible = true
	main_edit_panel.visible = false
	close_project()

func _on_ProjectFileDialog_file_selected(path):
	match project_file_dialog_mode:
		"New Project":
			new_project(path)
		"Open Project":
			load_project(path)
		"Save Project As":
			save_path = path
			export_project(save_path)

func _on_btn_project_save_pressed():
	if save_path:
		export_project(save_path)
	else:
		_on_btn_project_save_as_pressed()

func _on_btn_project_save_as_pressed():
	project_file_dialog_mode = "Save Project As"
	project_file_dialog.mode = FileDialog.MODE_SAVE_FILE
	project_file_dialog.popup_centered(Vector2(500, 600))

#-- LAYERS --#

func _on_btn_layer_add_pressed():
	create_new_layer()

func _on_btn_layer_remove_pressed():
	if layers_list.is_anything_selected():
		delete_layer(layers_list.get_selected_items()[0])

func _on_layer_list_item_selected(index):
	select_layer(index)

# Toggle the Shader editor on or off.
func _on_btn_run_pressed():
	set_playing_shader(not is_playing_shader)

#-- SETTINGS --#

var settings := {
	"default_shader": "res://assets/default_shader.tres",
	"default_shader_export": "[DEFAULT]",
	"default_texture": "res://test/bbg_citrus.png",
	"default_texture_export": "[DEFAULT]",
}

onready var default_shader = load_default_shader()
onready var default_texture = load_default_texture()

func get_abs_path(path : String):
	return (project_path + "/" + path).simplify_path()

func get_res_path(path : String):
	return ("res://" + path).simplify_path()

func make_abs_path_res(path : String):
	path = path.simplify_path()
	project_path = project_path.simplify_path()
	if project_path.is_subsequence_of(path):
		path = path.replace(project_path, "")
		path = path.simplify_path()
		return path
	return null

func get_godot_project_path(path : String):
	var dir := Directory.new()
	var dir_path := path.get_base_dir()
	dir.open(dir_path)
	
	while true:
		print('Looking for project.godot in ', dir.get_current_dir())
		if dir.file_exists("project.godot"):
			return dir.get_current_dir()
		var old_dir = dir.get_current_dir()
		var err = dir.change_dir("../")
		var new_dir = dir.get_current_dir()
		if old_dir == new_dir:
			break
		if not err == OK:
			break
	return null

func is_inside_godot_project(path : String):
	return project_path.simplify_path().is_subsequence_of(path.simplify_path())

#-- PROJECT --#

var shader_folder : String = "res://"
var texture_folder : String = "res://"
var save_path : String = "res://example_project.dsp"
var project_path : String = "res://"
var unsaved : bool = false

var opened_shaders := {}

func new_project(path : String):
	print("Creating new project at %s." % path)
	var godot_project_path = get_godot_project_path(path)
	
	if not godot_project_path:
		OS.alert("File must be inside of a Godot project.", "Couldn't find project.godot")
		return
	
	new_panel.visible = false
	main_edit_panel.visible = true
	
	close_project()
	
	project_path = godot_project_path
	shader_folder = "res://"
	texture_folder = "res://"
	save_path = path
	unsaved = false
	sampler_file_dialog.current_dir = godot_project_path
	
	export_project(path)

func close_project():
	# Remove all the current layers.
	for layer in layers_container.get_children():
		layers_container.remove_child(layer)
		layer.queue_free()
	layers_list.clear()
	clear_uniform_editors()
	for shader_edit in shaders_container.get_children():
		if shader_edit.name == "Preview":
			continue
		
		shaders_container.remove_child(shader_edit)
		shader_edit.queue_free()
	opened_shaders.clear()

func load_project(path : String):
	var file = ConfigFile.new()
	var err = file.load(path)
	
	if not err == OK:
		OS.alert("Malformed file.")
		return
	
	var godot_project_path = get_godot_project_path(path)
	sampler_file_dialog.current_dir = godot_project_path
	
	if godot_project_path == null:
		OS.alert("File must be inside of a Godot project.", "Couldn't find project.godot")
		return
	
	# TODO: Handle unsaved changes confirmation dialog.
	if unsaved:
		OS.alert("Ngl, there should be a confirmation dialog here.", "Discarding Unsaved Changes.")
	
	project_path = godot_project_path
	save_path = path
	
	shader_folder = file.get_value("", "shader_folder", "res://")
	texture_folder = file.get_value("", "texture_folder", "res://")
	
	close_project()
	
	var sections : Array = file.get_sections()
	sections.erase("")
	
	for layer in sections:
		var layer_view : Distortionator_LayerView = create_new_layer(false)
		var keys : Array = file.get_section_keys(layer)
		
		if not "shader" in keys:
			OS.alert("Must have a path to a shader... discarding layer.")
			break
		
		var shader_entry = file.get_value(layer, "shader")
		var shader
		if shader_entry == "[DEFAULT]":
			shader = load_default_shader()
		else:
			var shader_path = get_abs_path(shader_entry)
			shader = load_shader(shader_path)
			
			if shader and "code" in shader:
				OS.alert("Not a valid Shader resource.", "Discarding Layer.")
				continue
		
		layer_view.set_shader(shader)
		keys.erase("shader")
		
		if "texture" in keys:
			var texture_entry = file.get_value(layer, "texture")
			var texture
			
			if texture_entry == "[DEFAULT]":
				texture = load_default_texture()
			else:
				var texture_path = get_abs_path(texture_entry)
				texture = load_fileref(texture_path)
			
			if not texture:
				OS.alert("Not a valid texture path. TEXTURE will be unset.")
				continue
			
			layer_view.set_texture(texture)
			keys.erase("texture")
		
		if "texture_stretch" in keys:
			var texture_stretch_entry = file.get_value(layer, "texture_stretch")
			var texture_stretch = 2
			
			if texture_stretch_entry == "[DEFAULT]":
				texture_stretch = TextureRect.STRETCH_SCALE
			else:
				texture_stretch = [
					"STRETCH_SCALE_ON_EXPAND",
					"STRETCH_SCALE",
					"STRETCH_TILE",
					"STRETCH_KEEP"
				].find(texture_stretch_entry)
			
			layer_view.TEXTURE_STRETCH = texture_stretch
			keys.erase("texture_stretch")
		
		for uniform_name in keys:
			var uniform_value = file.get_value(layer, uniform_name, null)
			
			if uniform_value is String:
				if uniform_value.begins_with("[Resource]"):
					uniform_value = load_fileref(get_abs_path(uniform_value.trim_prefix("[Resource]")))
			
			layer_view.set_uniform(uniform_name, uniform_value)
	regenerate_uniform_editors()
	
	new_panel.visible = false
	main_edit_panel.visible = true
	update_window_title()


func export_project(path : String):
	var file = ConfigFile.new()
	
	file.set_value("", "shader_folder", shader_folder)
	file.set_value("", "texture_folder", shader_folder)
	
	for layer in layers_container.get_children():
		var section_name = layer.name
		var shader_path = make_abs_path_res(layer.SHADER.abs_path)
		
		if layer.SHADER.is_default:
			shader_path = settings.default_shader_export
		
		file.set_value(
			section_name,
			"shader",
			shader_path
		)
		
		if layer.TEXTURE:
			var texture_path = make_abs_path_res(layer.TEXTURE.abs_path)
			
			if layer.TEXTURE.is_default:
				texture_path = settings.default_texture_export
			
			file.set_value(
				section_name,
				"texture",
				texture_path
			)

			var texture_stretch = [
				"STRETCH_SCALE_ON_EXPAND",
				"STRETCH_SCALE",
				"STRETCH_TILE",
				"STRETCH_KEEP"
			][layer.TEXTURE_STRETCH]
			print(texture_stretch)

			file.set_value(
				section_name,
				"texture_stretch",
				texture_stretch
			)
		else:
			OS.alert("Layer %s has no texture. Saving anyways." % [
				layer.name
			])
		
		for uniform in layer.uniform_list.values():
			var uniform_value = uniform.value
			if uniform_value is FileRef:
				file.set_value(
					section_name, uniform.name,
					"[Resource]%s" % make_abs_path_res(uniform_value.abs_path)
				)
			else:
				file.set_value(section_name, uniform.name, uniform.value)
	
	update_window_title()
	
	file.save(path)

func update_window_title():
	OS.set_window_title(
		"Distortionator - %s%s" % [
			save_path,
			" (Unsaved)" if unsaved else ""
		]
	)

#-- BACKEND --#

var is_playing_shader : bool = false

func set_playing_shader(playing : bool):
	is_playing_shader = playing
	shader_edit_panel.visible = not playing
	
	$"p/v/HSplit/PropertyEditPanel/Toolbar/btn_run".icon = pause_icon if is_playing_shader else play_icon

func open_shader(shader_path : String, shader = null):
	print(opened_shaders)
	if shader is Shader:
		if not shader_path in opened_shaders.keys():
			opened_shaders[shader_path] = shader
			var shader_editor = shader_editor_scene.instance()
			shader_editor.text = shader.code
			shader_editor.readonly = true
			shaders_container.add_child(shader_editor, true)
			shaders_container.set_tab_title(shader_editor.get_index(), shader_path.get_file())
		return
	open_shader(shader_path, safe_load_resource(shader_path))

func safe_load_resource(path : String):
	return load(path)

## The currently selected layer, or -1 if no layer is selected.
var selected_layer : int = -1

func create_new_layer(use_defaults = true):
	var layer_view : Distortionator_LayerView = layer_view_scene.instance()
	layer_view.name = "Layer 0"
	layers_container.add_child(layer_view, true)
	
	if use_defaults:
		layer_view.set_shader(
			default_shader
		)
		
		layer_view.set_texture(default_texture)
	
	layers_list.add_item(layer_view.name)
	layers_list.select(layers_list.get_item_count() - 1)
	
	select_layer(layers_list.get_item_count() - 1)
	
	return layer_view

func delete_layer(index : int):
	layers_container.get_child(index).free()
	layers_list.remove_item(index)
	if layers_list.get_item_count() > 0:
		var new_index = min(index, layers_list.get_item_count() - 1)
		layers_list.select(new_index)
		select_layer(new_index)
	else:
		clear_uniform_editors()

func move_layer(index : int, to : int):
	layers_list.move_item(index, to)
	layers_container.move_child(layers_container.get_child(index), to)

func select_layer(index):
	selected_layer = index
	regenerate_uniform_editors()

func regenerate_uniform_editors():
	clear_uniform_editors()
	
	if not selected_layer in range(layers_container.get_child_count()):
		return
	
	var layer_view = layers_container.get_child(selected_layer)
	
	var TEXTURE_editor : PropertyPicker = property_editor_scene.instance()
	TEXTURE_editor.d_core = self
	TEXTURE_editor.sampler_file_dialog = sampler_file_dialog
	TEXTURE_editor.setup(layer_view, "TEXTURE", "sampler2D")
	TEXTURE_editor.set_value_no_signal(layer_view.texture, true)
	layer_property_editors_container.add_child(TEXTURE_editor, true)
	
	for i in layer_view.uniform_list.values():
		var uniform_editor : UniformEditor = uniform_editor_scene.instance()
		uniform_editor.d_core = self
		uniform_editor.sampler_file_dialog = sampler_file_dialog
		uniform_editor.setup(i)
		uniform_editors_container.add_child(uniform_editor, true)
		uniform_editor.connect("uset", self, "set_layer_uniform")
	
	parameter_dock.name = layers_container.get_child(selected_layer).name

func clear_uniform_editors():
	for i in layer_property_editors_container.get_children():
		layer_property_editors_container.remove_child(i)
		i.free()
	for i in uniform_editors_container.get_children():
		uniform_editors_container.remove_child(i)
		i.free()

func set_layer_uniform(uniform : String, value):
	var current_layer : Distortionator_LayerView = layers_container.get_child(selected_layer)
	print("Setting uniform %s to %s." % [uniform, value])
	current_layer.set_uniform(uniform, value)

func load_shader(shader_path : String):
	var shader = load(shader_path)
	if shader:
		open_shader(shader_path)
		return FileRef.create(project_path, shader, shader_path)
	return null

func load_default_shader():
	var shader_path = settings.default_shader
	var shader = load(shader_path)
	if shader:
		open_shader(shader_path)
		return FileRef.create(project_path, shader, shader_path, true)
	return null

func load_default_texture():
	var file_path = settings.default_texture
	var file = load(file_path)
	
	if file:
		var f = FileRef.create(project_path, file, file_path, true)
		return f
	return null

func load_fileref(file_path : String):
	var file
	
	if file_path.ends_with(".png"):
		file = load_png(file_path)
	else:
		file = load(file_path)
	
	if file:
		return FileRef.create(project_path, file, file_path)
	
	return null

func load_png(file_path : String):
	var f := File.new()
	if f.open(file_path, File.READ) == OK:
		var img := Image.new()
		img.load_png_from_buffer(f.get_buffer(f.get_len()))
		var img_tex := ImageTexture.new()
		img.clear_mipmaps()
		img_tex.create_from_image(img, 1)
		img_tex.flags = 2
		
		return img_tex
	return null

var frame_no := 0
var recording_frames := false
var export_dir

func get_frames_export_path():
	return project_path + "/_tmp/"

func begin_exporting_gif():
	export_dir = Directory.new()
	var exdir = get_frames_export_path()
	print("Exporting frames at " + exdir)
	export_dir.open(exdir.get_base_dir())
	if not export_dir.dir_exists(exdir):
		export_dir.make_dir(exdir)
	frame_no = 0
	recording_frames = true
	export_frame()

func end_exporting_gif():
	recording_frames = false

func export_frame():
	layers_gif_recorder.render_to_file(get_frames_export_path() + save_path.get_file().get_basename() + '.gif')
	yield(layers_gif_recorder, 'done_encoding')

	print('Done encoding GIF!')

	layers_gif_recorder.clear()
	layers_gif_recorder.start()
	
	return
	var img := layers_viewport.get_texture().get_data()
	img.save_png(get_frames_export_path() + "frame_" + str(frame_no) + ".png")
	frame_no += 1

func _on_record_toggled(button_pressed):
	if button_pressed:
		begin_exporting_gif()
	else:
		end_exporting_gif()

func process_frames_recording():
	pass

func _process(delta):
	if recording_frames:
		process_frames_recording()


func _on_GifRecorder_encoding_progress(percentage, frames_done):
	print("Encoding GIF: ", percentage, "%.")
