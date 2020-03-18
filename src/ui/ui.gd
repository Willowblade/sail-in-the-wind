extends CanvasLayer


onready var island_name_view = $IslandNameView
onready var animation_player = $AnimationPlayer
onready var name_island_dialog = $NameIslandDialog

onready var menus = {
	"escape": get_node("EscapeMenu")
}

var enabled = false

var open_uis = []



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
	animation_player.play("name_label")
	
func show_name_island_dialog():
	name_island_dialog.popup_centered()
	
func _on_name_island_closed():
	print("Modal closed, ", name_island_dialog.get_node("LineEdit").text)
	
