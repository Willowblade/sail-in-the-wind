extends Sprite


onready var animation_player: AnimationPlayer = $AnimationPlayer

signal finished


onready var textures = { 
	"wood_settlement_small": load("res://assets/graphics/settlements/settlement_wood_0.png"),
	"wood_settlement_medium": load("res://assets/graphics/settlements/settlement_wood_1.png"),
	"wood_settlement_large": load("res://assets/graphics/settlements/settlement_wood_2.png"),
	"food_settlement_small": load("res://assets/graphics/settlements/settlement_food_0.png"),
	"food_settlement_medium": load("res://assets/graphics/settlements/settlement_food_1.png"),
	"food_settlement_large": load("res://assets/graphics/settlements/settlement_food_2.png"),
	"metal_settlement_small": load("res://assets/graphics/settlements/settlement_steel_0.png"),
	"metal_settlement_medium": load("res://assets/graphics/settlements/settlement_steel_1.png"),
	"metal_settlement_large": load("res://assets/graphics/settlements/settlement_steel_2.png"),
	"harbor": load("res://assets/graphics/settlements/harbor.png"),
	"harbor_finished": load("res://assets/graphics/settlements/harbor_finished.png"),
}

var animation_speed = 0.75

func set_sprite(tile_name):
	if not tile_name in textures:
		print("Tile ", tile_name, " does not exist!")
	texture = textures[tile_name]

func play():
	animation_player.playback_speed = animation_speed
	animation_player.play("build")

func _ready():
	animation_player.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished(__: String):
	emit_signal("finished")
