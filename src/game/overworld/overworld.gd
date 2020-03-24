extends Node2D


onready var large_boat = $Entities/LargeBoat
onready var islands = $Islands
onready var camera = $Entities/LargeBoat/Camera
onready var water = $Water

onready var creation_tile_scene = preload("res://src/game/overworld/CreationTile.tscn")
onready var small_boat_scene = preload("res://src/game/player/SmallBoat.tscn")

export var audio_track: String = ""

var current_island: Island = null

onready var _flag = $Flag

onready var anchor = $Anchor

var player_start

var small_boat
var player

var current_track: String

signal in_island(is_in_island)
signal interacting(is_interacting)
signal founding(is_founding)

func _ready():
	UI.start_game()
	current_track = "res://assets/audio/sea.ogg"
	player = large_boat
	player_start = player.position
	if audio_track != "":
		AudioEngine.play_background_music(audio_track)
		
#	for interaction in get_tree().get_nodes_in_group("interactive"):
#		player.connect("interact", interaction, "_on_player_interacted")
#
#	if Transitions.position_to_transition_to != null:
#		set_player_position(Transitions.position_to_transition_to)
	
	for island in islands.get_children():
		island.connect("island_entered", self, "_body_entered_island")
		island.connect("island_exited", self, "_body_exited_island")
	
	connect("founding", UI, "_on_founding")
	connect("in_island", UI, "_on_in_island")
	connect("interacting", UI, "_on_interacting")
	UI.connect("island_named", self, "_on_island_named")
	UI.connect("settle", self, "_on_settle_pressed")
	UI.connect("new_player_name", self, "_on_new_player_name")
	UI.stamina.connect("food_empty", self, "_on_food_empty")
	if not GameState.game_state.get("player", {}).get("name"):
		UI.show_decree()

	player.connect("deploy_small_boat", self, "_on_deploy_small_boat")

func _on_deploy_small_boat():
	# TODO CLEAN
	UI.controls.get_node("Boat").hide() # it just gets uglier...
	if small_boat != null:
		print("There is already a small boat")
		return
	if current_island != null:
		deploy_small_boat()

func deploy_small_boat():
	small_boat = small_boat_scene.instance()
	$Entities.add_child(small_boat)
	small_boat.position = player.position + Vector2(0, 16)
	small_boat.connect("return_small_boat", self, "_on_return_small_boat")
	large_boat.remove_child(camera)
	small_boat.add_child(camera)
	player = small_boat
	large_boat.set_physics_process(false)

func _on_return_small_boat():
	return_small_boat()

func return_small_boat():
	small_boat.remove_child(camera)
	large_boat.add_child(camera)
	small_boat.queue_free()
	$Entities.remove_child(small_boat)
	small_boat = null
	player = large_boat
	large_boat.set_physics_process(true)
	# TODO CLEAN
	UI.controls.get_node("Boat").show() # it just gets uglier...
		
func restart():
	if small_boat:
		return_small_boat()
	player.position = player_start
	GameState.game_state.inventory.contents = ["food", "food", "food", "wood", "wood"]
	GameState.game_state.gold = 500
	GameState.send_changed()

func _on_new_player_name(new_player_data):
	GameState.game_state["player"] = new_player_data
	player.player_name = new_player_data.name
	player.boat_name = new_player_data.boat_name

func _on_food_empty():
	Transitions.fade_to_opaque()
	yield(Transitions, "transition_completed")
	restart()
	player.set_physics_process(false)
	Transitions.fade_to_transparant()
	yield(Transitions, "transition_completed")
	UI.show_restart_decree()
	player.set_physics_process(true)

func draw_water_around_player():
	water.clear()
	var water_tile_id = water.tile_set.find_tile_by_name("water")

	for x in range(-11, 12):
		for y in range(-9, 9):
			var tile_position = water.world_to_map(player.position + Vector2(x * 16, y * 16))
			water.set_cellv(tile_position, water_tile_id)

func _body_entered_island(island, body):
	if body is LargeBoat:
		current_island = island
		if current_island.audio_track != "":
			current_track = current_island.audio_track
			AudioEngine.play_background_music(current_track)
		if current_island.island_name != "":
			UI.show_island_name(current_island.island_name)
		else:
			UI.show_name_island(current_island)
		emit_signal("in_island", true)
	update()

func _body_exited_island(island, body):
	if body is LargeBoat:
		current_island = null
		current_track = "res://assets/audio/sea.ogg"
		AudioEngine.play_background_music(current_track)
		emit_signal("in_island", false)
	update()
	
func show_anchor():
	anchor.show()
	anchor.position = player.position

func hide_anchor():
	anchor.hide()
		
func _physics_process(delta):
	AudioEngine.play_background_music(current_track)
	UI.update_minimap(player)
	draw_water_around_player()

	if Input.is_action_just_pressed("ui_map"):
		UI.show_map(player)
		return
	
	if current_island:
		var interactable_tiles = get_interactable_tiles()
		if interactable_tiles != null:
			if interactable_tiles.type == "settle":
				if current_island.settled:
					emit_signal("founding", false)
					update()
					hide_flag()
					return
				show_flag(interactable_tiles["land"]["coordinates"])
				emit_signal("founding", true)
			elif interactable_tiles.type == "settlement":
				show_anchor()
				emit_signal("interacting", true)
			elif interactable_tiles.type == "capital":
				show_anchor()
				emit_signal("interacting", true)
			else:
				print("Unknown interaction")
				print(interactable_tiles)
	#		print(interactable_tiles)
		else:
			emit_signal("founding", false)
			emit_signal("interacting", false)
			hide_anchor()
			hide_flag()
			
		if Input.is_action_just_pressed("ui_accept"):
			if _flag.visible:
				UI.open_settle()
				emit_signal("founding", false)
			elif anchor.visible:
				if interactable_tiles.type == "capital":
					UI.open_shop(current_island, true)
				else:
					UI.open_shop(current_island, false)
		update()

	

func get_interactable_tiles():
	var interact_position = player.global_position + 8 * player.direction
	if current_island.tile_is_coast(interact_position):
		var coast_tile = current_island.get_coast_tile(interact_position)
		interact_position += 16 * player.direction
		if current_island.has_island_tile_at_position(interact_position):
			if current_island.tile_is_occupied(interact_position):
				var contents_tile = current_island.get_contents_tile(interact_position)
				var contents_tile_name = contents_tile.tile_name
				if contents_tile_name.begins_with("capital_gate"):
					return {
						"type": "capital",
						"contents": contents_tile
					}
				elif "settlement" in contents_tile_name:
					return {
						"type": "settlement",
						"contents": contents_tile
					}
			else:
				var land_tile = current_island.get_tile_at_position(interact_position)
				if land_tile.name.begins_with("land"):
					return {
						"type": "settle",
						"coast": coast_tile,
						"land": land_tile,
						"direction": player.direction,
					}
					
func _on_island_named(island_name: String):
	current_island.island_name = island_name
	UI.show_island_name(island_name)
	GameState.add_gold(300)
	
func _on_settle_pressed():
	if not GameState.has_item("wood", 1):
		return
	GameState.remove_item("wood")
	current_island.settled = true
	var interactable_tiles = get_interactable_tiles()
	player.set_physics_process(false)
	var harbor_creation_tile = creation_tile_scene.instance()
	add_child(harbor_creation_tile)
	harbor_creation_tile.position = interactable_tiles.coast.coordinates + Vector2(8, 8)
	if interactable_tiles.direction == Vector2(0, 1):
		harbor_creation_tile.rotation_degrees = 180
	elif interactable_tiles.direction == Vector2(0, -1):
		harbor_creation_tile.rotation_degrees = 0
	elif interactable_tiles.direction == Vector2(1, 0):
		harbor_creation_tile.rotation_degrees = 90
	elif interactable_tiles.direction == Vector2(-1, 0):
		harbor_creation_tile.rotation_degrees = -90
	harbor_creation_tile.set_sprite("harbor")
	harbor_creation_tile.play()
	yield(harbor_creation_tile, "finished")
	harbor_creation_tile.set_sprite("harbor_finished")
	var settlement_creation_tile = creation_tile_scene.instance()
	add_child(settlement_creation_tile)
	settlement_creation_tile.position = interactable_tiles.land.coordinates + Vector2(8, 8)
	settlement_creation_tile.set_sprite("wood_settlement_large")
	settlement_creation_tile.play()
	yield(settlement_creation_tile, "finished")
	current_island.settle(interactable_tiles)
	harbor_creation_tile.queue_free()
	settlement_creation_tile.queue_free()
	player.set_physics_process(true)
	GameState.add_gold(500)
	
func _draw():
	if current_island != null and GameState.DEBUG == true:
		draw_circle(player.global_position + 8 * player.direction, 2, Color(0, 0, 0))
		draw_circle(player.global_position + 8 * player.direction, 1, Color(1, 1, 1))
		draw_circle(player.global_position + 24 * player.direction, 2, Color(0, 0, 0))
		draw_circle(player.global_position + 24 * player.direction, 1, Color(1, 1, 1))
		
func show_flag(coordinates: Vector2):
	if not _flag.visible:
		AudioEngine.play_effect("res://assets/audio/sfx/navigation/flag_on.ogg")
	_flag.global_position = coordinates
	_flag.show()
	
func hide_flag():
	_flag.hide()
	
