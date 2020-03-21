extends CanvasLayer


onready var island_name_view = $IslandNameView
onready var animation_player = $AnimationPlayer
onready var name_island_dialog = $NameIslandDialog
onready var settle_dialog = $SettleDialog
onready var inventory = $Inventory


onready var menus = {
	"escape": get_node("EscapeMenu")
}

var enabled = false

var open_uis = []




signal island_named(island_name)
signal settle()


func _ready():
	disable()
	
	for child in get_children():
		if child == animation_player:
			continue
		child.hide()
	
	for child in menus.values():
		child.connect("close", self, "_on_close_ui")

	name_island_dialog.connect("popup_hide", self, "_on_name_island_closed")
	island_name_view.show()
	inventory.show()

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
	
