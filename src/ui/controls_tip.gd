extends Control

export var text = ""
export(String, FILE, "*.png") var image_texture = ""

func _ready():
	var size = $HBoxContainer/Keyboard.texture.get_size()
	$HBoxContainer/Keyboard.rect_min_size.x = 2 * size.x
	if image_texture != "":
		$HBoxContainer/Text.text = ": "
		$HBoxContainer/TextureRect.show()
		$HBoxContainer/TextureRect.texture = load(image_texture)
	else:
		$HBoxContainer/TextureRect.hide()
		$HBoxContainer/Text.text = ": " + text

