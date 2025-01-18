extends TextureRect

export var viewport_path : NodePath setget set_viewport_path

func set_viewport_path(path):
	viewport_path = path
	if path:
		var viewport = get_node_or_null(viewport_path)
		if viewport:
			texture = viewport.get_texture()

func _ready():
	if viewport_path:
		texture = get_node(viewport_path).get_texture()


func _on_width_value_changed(value):
	var viewport: Viewport = get_node(viewport_path)
	viewport.size.x = value
	update()

func _on_height_value_changed(value):
	var viewport: Viewport = get_node(viewport_path)
	viewport.size.y = value
	update()

func _on_CheckBox_toggled(button_pressed):
	stretch_mode = STRETCH_KEEP_ASPECT_CENTERED if button_pressed else STRETCH_KEEP_CENTERED
