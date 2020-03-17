extends Node2D


onready var player = $Entities/LargeBoat
onready var islands = $Islands
onready var camera = $Entities/LargeBoat/Camera

export var audio_track: String = ""

var current_island: Island = null

var DEBUG = true


func _ready():
	if audio_track != "":
		AudioEngine.play_sound(audio_track)
		
#	for interaction in get_tree().get_nodes_in_group("interactive"):
#		player.connect("interact", interaction, "_on_player_interacted")
#
#	if Transitions.position_to_transition_to != null:
#		set_player_position(Transitions.position_to_transition_to)
	
	for island in islands.get_children():
		island.connect("island_entered", self, "_body_entered_island")
		island.connect("island_exited", self, "_body_exited_island")
		
	set_physics_process(false)
		

func _body_entered_island(island, body):
	if body is Player:
		current_island = island
		set_physics_process(true)
	update()

func _body_exited_island(island, body):
	if body is Player:
		current_island = null
		set_physics_process(false)
	update()
		
func _physics_process(delta):
	var interactable_tiles = get_interactable_tiles()
	if interactable_tiles != null:
		print(interactable_tiles)
	update()

func get_interactable_tiles():
	var interact_position = player.global_position + 8 * player.direction
	if current_island.has_tile_at_position(interact_position):
		var coast_tile = current_island.get_tile_at_position(interact_position)
		if coast_tile.name == "atlas":
			interact_position += 16 * player.direction
			if current_island.has_tile_at_position(interact_position):
				var land_tile = current_island.get_tile_at_position(interact_position)
				if land_tile.name.begins_with("land"):
					return {
						"coast": coast_tile,
						"land": land_tile
					}
					
func _draw():
	if current_island != null and DEBUG == true:
		draw_circle(player.global_position + 8 * player.direction, 2, Color(0, 0, 0))
		draw_circle(player.global_position + 8 * player.direction, 1, Color(1, 1, 1))
		draw_circle(player.global_position + 24 * player.direction, 2, Color(0, 0, 0))
		draw_circle(player.global_position + 24 * player.direction, 1, Color(1, 1, 1))
