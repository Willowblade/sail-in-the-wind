extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_node("Entities/Character")

export var audio_track: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	if audio_track != "":
		AudioEngine.play_sound(audio_track)
		
	for interaction in get_tree().get_nodes_in_group("interactive"):
		player.connect("interact", interaction, "_on_player_interacted")
		
	if Transitions.position_to_transition_to != null:
		set_player_position(Transitions.position_to_transition_to)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_player_position(player_position: Vector2):
	player.position = player_position
