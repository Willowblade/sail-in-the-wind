extends CanvasLayer


onready var island_name_view = $IslandNameView
onready var animation_player = $AnimationPlayer
onready var name_island = $NameIsland
onready var settle = $Settle
onready var inventory = $Inventory
onready var gold_count = $GoldCount
onready var stamina = $Stamina
onready var ship_upgrades = $ShipUpgrades
onready var island_shop = $IslandShop
onready var map = $Map
onready var minimap = $Minimap
onready var controls = $Controls
onready var instructions = $Instructions

onready var decree = $Decree
onready var restart_decree = $RestartDecree

onready var menus = {
	"escape": get_node("EscapeMenu")
}

var enabled = false

var open_uis = []


var in_island

signal island_named(island_name)
signal settle()
signal new_player_name(player_name_data)


var button_pressed = null

func _ready():
	disable()

	GameState.connect("updated_game_state", self, "on_updated_game_state")
	
	for child in get_children():
		if child == animation_player:
			continue
		child.hide()
	
	for child in menus.values():
		child.connect("close", self, "_on_close_ui")

	island_name_view.show()


	decree.connect("done", self, "_on_decree_done")
	restart_decree.connect("done", self, "_on_restart_decree_done")
	instructions.connect("done", self, "_on_instructions_done")
	settle.connect("done", self, "_on_settle_done")
	name_island.connect("done", self, "_on_name_island_done")
	on_updated_game_state()
	
	if GameState.DEBUG == true:
		enable()

func _on_in_island(is_in_island):
	in_island = is_in_island
	if is_in_island:
		if GameState.game_state.upgrades.small_boat == 1:
			$Controls/Boat.show()
	else:
		if GameState.game_state.upgrades.small_boat == 1:
			$Controls/Boat.hide()
			
func _on_interacting(is_interacting):
	if is_interacting:
		$Controls/Interact.show()
	else:
		$Controls/Interact.hide()

func _on_founding(is_founding):
	if is_founding:
		$Controls/Settle.show()
	else:
		$Controls/Settle.hide()


func pause_game():
	get_tree().paused = true
	stamina.pause()
	stop_game()
	
func resume_game():
	get_tree().paused = false
	stamina.play()
	start_game()

func open_shop(island: Island, is_capital: bool):
	pause_game()
	AudioEngine.play_effect("assets/audio/sfx/navigation/boat_arrive.ogg")
	AudioEngine.play_background_music("assets/audio/sfx/navigation/shx_city_slower.ogg")
	island_shop.set_island(island)
	island_shop.show()
	inventory.show()
	gold_count.show()
	ship_upgrades.set_physics_process(false)
	island_shop.set_physics_process(true)
	if is_capital:
		island_shop.add_upgrades()
	else:
		island_shop.remove_upgrades()
		
func close_shops():
	island_shop.hide()
	ship_upgrades.hide()
	ship_upgrades.set_physics_process(false)
	island_shop.set_physics_process(false)
	AudioEngine.play_effect("assets/audio/sfx/navigation/boat_leaving.ogg")
	resume_game()
	
func toggle_upgrades():
	if island_shop.visible:
		island_shop.hide()
		ship_upgrades.show()
		ship_upgrades.set_physics_process(true)
		island_shop.set_physics_process(false)
	else:
		island_shop.show()
		ship_upgrades.hide()
		ship_upgrades.set_physics_process(false)
		island_shop.set_physics_process(true)

func show_interact():
	$Controls/Interact.show()


func hide_interact():
	$Controls/Interact.hide()
	


func update_minimap(player: Player):
	minimap.load_islands(player)
		
func start_game():
	inventory.show()
	gold_count.show()
	stamina.show()
	stamina.play()
	minimap.show()
	controls.show()
	enable()
	
		
func stop_game():
	inventory.hide()
	gold_count.hide()
	stamina.hide()
	stamina.pause()
	minimap.hide()
	controls.hide()
#	disable()

	
func on_updated_game_state():
	gold_count.get_node("Label").text = ": " + str(GameState.game_state["gold"])
	if GameState.game_state.upgrades.small_boat == 1:
		if in_island:
			$Controls/Boat.show()
	else:
		$Controls/Boat.hide()
	
func _on_restart_decree_done():
	resume_game()
	restart_decree.hide()
	restart_decree.set_physics_process(false)

func _on_instructions_done():
	print("On instructions done...")
	resume_game()
	instructions.hide()
	instructions.set_physics_process(false)

func _on_decree_done(decree_data):
	emit_signal("new_player_name", decree_data)
	decree.hide()
	decree.set_physics_process(false)
	instructions.show()
	instructions.activate()
	yield(get_tree().create_timer(0.2), "timeout")
	instructions.set_physics_process(true)
	
		
func show_decree():
	pause_game()
	decree.show()
	decree.activate()
	decree.set_physics_process(true)

func show_restart_decree():
	restart_decree.show()
	restart_decree.activate()
	restart_decree.set_physics_process(true)
	pause_game()

func enable():
	enabled = true
	set_process_input(true)

func disable():
	enabled = false
	set_process_input(false)

func reset():
	for child in get_children():
		if child != animation_player:
			child.hide()
	open_uis.clear()
	Flow.resume()

func open_ui(ui_name, information=null):
	# naming is a soupie here.
	var menu = menus[ui_name]
	if information:
		menu.initialize(information)
	menu.show()
	if menu.should_pause:
		pause_game()
		
	open_uis.append(menu)

func _on_close_ui(menu):
	menu.hide()
	open_uis.erase(menu)
	resume_game()
#	if menu.should_pause:
#		for open_ui in open_uis:
#			if open_ui.should_pause:
#				return

func close_settle():
	pass


func _on_near_large_boat(is_near_large_boat):
	if is_near_large_boat:
		$Controls/LargeBoat.show()
	else:
		$Controls/LargeBoat.hide()

func show_map(player):
	pause_game()
	map.load_islands(player)
	map.show()


func hide_map():
	map.hide()
	resume_game()


func _input(event):
	if not enabled:
		print("Something wrong with UI")
		return
		
	if Input.is_action_just_pressed("ui_cancel"):
		if name_island.visible:
			# have to name the island. Box still needs theming!
			pass
		elif settle.visible:
			close_settle()
		elif map.visible:
			hide_map()
		elif ship_upgrades.visible:
			close_shops()
		elif island_shop.visible:
			close_shops()
		elif decree.visible:
			pass
		else:
			pass
#			open_ui("escape")

	# elif Input.is_action_just_pressed("ui_map"):
	# 	if map.visible:
	# 		print("Closing map")
	# 		hide_map()

	elif Input.is_key_pressed(KEY_1): 
		if button_pressed != KEY_1:
			GameState.add_gold(100)
		button_pressed = KEY_1
	elif Input.is_key_pressed(KEY_2): 
		if button_pressed != KEY_2:
			GameState.add_gold(-100)
		button_pressed = KEY_2
	elif Input.is_key_pressed(KEY_3): 
		if button_pressed != KEY_3:
			GameState.add_gold(10)
		button_pressed = KEY_3
	elif Input.is_key_pressed(KEY_4): 
		if button_pressed != KEY_4:
			GameState.add_gold(-10)
		button_pressed = KEY_4
	elif Input.is_key_pressed(KEY_5): 
		if button_pressed != KEY_5:
			GameState.add_inventory_space(1)
		button_pressed = KEY_5
	elif Input.is_key_pressed(KEY_6): 
		if button_pressed != KEY_6:
			GameState.add_inventory_space(-1)
		button_pressed = KEY_6
	elif Input.is_key_pressed(KEY_7): 
		if button_pressed != KEY_7:
			GameState.add_item("food")
		button_pressed = KEY_7
	elif Input.is_key_pressed(KEY_8): 
		if button_pressed != KEY_8:
			GameState.add_item("wood")
		button_pressed = KEY_8
	elif Input.is_key_pressed(KEY_9): 
		if button_pressed != KEY_9:
			GameState.add_item("metal")
		button_pressed = KEY_9
	elif Input.is_key_pressed(KEY_0): 
		if button_pressed != KEY_0:
			if GameState.game_state.inventory.contents.size():
				GameState.remove_item(GameState.game_state.inventory.contents[GameState.game_state.inventory.contents.size() - 1])
		button_pressed = KEY_0
	else:
		button_pressed = null
	

func show_island_name(island_name: String):
	island_name_view.get_node("Label").text = island_name
	island_name_view.get_node("Panel").rect_min_size = island_name_view.get_node("Label").get_minimum_size()
#	island_name_view.get_node("Panel").rect_position.x = island_name_view.get_node("Label").rect_position.x + island_name_view.get_node("Label").get_minimum_size().x / 3 
	print(-island_name_view.get_node("Panel").rect_position.x)
	if animation_player.current_animation == "name_label":
		animation_player.stop(true)
	animation_player.play("name_label")
	
func show_name_island(island: Island):
	pause_game()
	name_island.show()
	name_island.activate()
	name_island.set_island(island)
	name_island.set_physics_process(true)
	
func _on_name_island_done(island_name):
	resume_game()
	emit_signal("island_named", island_name.name)
	AudioEngine.play_effect("assets/audio/sfx/navigation/island_name.ogg")
	name_island.hide()
	name_island.set_physics_process(false)

func open_settle():
	pause_game()
	settle.show()
	settle.activate()
	settle.set_physics_process(true)

	
func _on_settle_done():
	resume_game()
	emit_signal("settle")
	settle.hide()
	settle.set_physics_process(false)

	
	
