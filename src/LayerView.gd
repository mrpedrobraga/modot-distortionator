extends TextureRect
class_name Distortionator_LayerView

var TEXTURE = null setget set_texture
var TEXTURE_STRETCH = TextureRect.STRETCH_TILE
var SHADER = null
var uniform_list := {}

func _ready():
	material = ShaderMaterial.new()

func set_shader(shader):
	if shader is FileRef:
		SHADER = shader
	shader = shader.file
	material.shader = shader
	uniform_list = ShaderInspector.get_uniform_list(shader.code)

func set_texture(new_texture):
	if new_texture is FileRef:
		texture = new_texture.file
		TEXTURE = new_texture

func set_uniform(uniform_name : String, value):
	if not uniform_name in uniform_list.keys():
		OS.alert("Unknown uniform '%s' for layer '%s'." % [uniform_name, name])
		return
	
	material.set_shader_param(uniform_name, value.file if value is FileRef else value)
	uniform_list[uniform_name].value = value

func get_uniform(uniform_name : String, value):
	if not uniform_name in uniform_list.keys():
		OS.alert("Unknown uniform '%s' for layer '%s'." % [uniform_name, name])
		return
	
	return material.get_shader_param(uniform_name)
