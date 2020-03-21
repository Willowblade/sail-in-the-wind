extends TextureRect

onready var contents = $Contents


onready var frame_textures = {
	"free": load("res://assets/graphics/ui/item-rect.png"),
	"taken": load("res://assets/graphics/ui/item-rect-taken.png"),
	"free-alternative": load("res://assets/graphics/ui/item-rect-alternative.png"),
	"taken-alternative": load("res://assets/graphics/ui/item-rect-alternative-taken.png"),
}

onready var contents_textures = { 
	"wood": load("res://assets/graphics/decorations/wood.png"),
	"food": load("res://assets/graphics/decorations/food.png"),
	"metal": load("res://assets/graphics/decorations/metal.png"),
}

func _ready():
	pass

func set_contents(content_name: String):
	if content_name == null:
		texture = frame_textures.free
		contents.texture = null
	else:
		texture = frame_textures.taken
		contents.texture = contents_textures[content_name]
