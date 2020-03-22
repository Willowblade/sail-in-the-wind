extends CanvasLayer


onready var island_name_view = $IslandNameView
onready var animation_player = $AnimationPlayer
onready var name_island_dialog = $NameIslandDialog
onready var settle_dialog = $SettleDialog
onready var inventory = $Inventory
onready var gold_count = $GoldCount

onready var decree = $Decree

onready var menus = {
	"escape": get_node("EscapeMenu")
}

var enabled = false

var open_uis = []


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

	name_island_dialog.connect("popup_hide", self, "_on_name_island_closed")
	island_name_view.show()
	inventory.show()

	decree.connect("done", self, "_on_decree_done")
	on_updated_game_state()
	gold_count.show()
	
	if GameState.DEBUG == true:
		set_physics_process(true)
	else:
		set_physics_process(false)


func _physics_process(delta):
	if Input.is_key_pressed(KEY_1): 
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
	
func on_updated_game_state():
	gold_count.get_node("Label").text = ": " + str(GameState.game_state["gold"])
	
func _on_decree_done(decree_data):
	get_tree().paused = false
	decree.hide()
	decree.set_physics_process(false)
	emit_signal("new_player_name", decree_data)
	
func show_decree():
	decree.show()
	decree.activate()
	decree.set_physics_process(true)
	get_tree().paused = true

func enable():
	enabled = true
	set_process_input(true)

func disable():
	enabled = false
	set_process_input(false)

func reset():
	for child in get_children():
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
		Flow.pause()
		
	open_uis.append(menu)

func _on_close_ui(menu):
	menu.hide()
	open_uis.erase(menu)
	if menu.should_pause:
		for open_ui in open_uis:
			if open_ui.should_pause:
				return
		Flow.resume()

func _input(event):
	if not enabled:
		print("Something wrong with UI")
		return
		
	if Input.is_action_just_pressed("ui_menu"):
		open_ui("escape")
		

func show_island_name(island_name: String):
	island_name_view.get_node("Label").text = island_name
	island_name_view.get_node("Panel").rect_min_size = island_name_view.get_node("Label").get_minimum_size()
#	island_name_view.get_node("Panel").rect_position.x = island_name_view.get_node("Label").rect_position.x + island_name_view.get_node("Label").get_minimum_size().x / 3 
	print(-island_name_view.get_node("Panel").rect_position.x)
	if animation_player.current_animation == "name_label":
		animation_player.stop(true)
	animation_player.play("name_label")
	
func show_name_island_dialog():
	get_tree().paused = true
	name_island_dialog.popup_centered()
	
func _on_name_island_closed():
	get_tree().paused = false
	var text = name_island_dialog.get_node("LineEdit").text
	print("Modal closed, ", text)
	emit_signal("island_named", text)

func settle():
	get_tree().paused = true
	settle_dialog.connect("confirmed", self, "_on_settle_confirmed")
	settle_dialog.connect("popup_hide", self, "_on_settle_denied")
	settle_dialog.show_modal(true)
	
func _on_settle_confirmed():
	emit_signal("settle")
	get_tree().paused = false
	
func _on_settle_denied():
	get_tree().paused = false
	
