extends Node


var position_to_transition_to = null

func _ready():
	pass # Replace with function body.

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
