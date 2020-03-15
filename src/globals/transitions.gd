extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var position_to_transition_to = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func transition_to(destination: PackedScene, location: Vector2):
	print("Going to ", destination, " with location ", location)
	AudioEngine.reset()
	get_tree().change_scene_to(destination)
	position_to_transition_to = location

func transition_to_path(destination: String, location: Vector2):
	print("Going to ", destination, " with location ", location)
	AudioEngine.reset()
	get_tree().change_scene(destination)
	position_to_transition_to = location
