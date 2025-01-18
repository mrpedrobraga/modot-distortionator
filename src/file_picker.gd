extends HBoxContainer

export var file_dialog_path : NodePath
var file_dialog : FileDialog

signal file_picked(file)

export var filesystem_root_path := "res://"
export var current_file_path := "res://"

func _ready():
	file_dialog = get_node(file_dialog_path)

func _on_btn_open_dialog_pressed():
	file_dialog.popup_centered(Vector2(600, 500))

func clear():
	$txt_res_path.text = ""
	current_file_path = "res://"

func pick_file(path : String):
	$txt_res_path.text = path
	current_file_path = path
