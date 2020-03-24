extends Control

onready var marker = $Marker

onready var upgrades = $Upgrades.get_children()

var marker_locations = {}
var marker_positions = []


func _ready():
	for upgrade in upgrades:
		print(upgrade.name)
	generate_marker_locations()

func generate_marker_locations():
	marker_positions = []
	marker_locations = {}
	for upgrade in upgrades:
		var location = upgrade.rect_position - Vector2(32, 0) + Vector2(0, 8)
		marker_locations[location] = upgrade
		marker_positions.append(location)
	marker.rect_position = marker_positions[0]

func _physics_process(delta):
	if not visible:
		return
		
	if marker_positions.size() == 0:
		return
	
	if Input.is_action_just_pressed("ui_focus_next"):
			UI.toggle_upgrades()

	if Input.is_action_just_pressed("ui_left"):
		var marker_position_index = marker_positions.find(marker.rect_position)
		marker.rect_position = marker_positions[(marker_position_index + marker_positions.size() - 1) % marker_positions.size()]
		AudioEngine.play_effect("res://assets/audio/sfx/navigation/select_item.ogg")
	elif Input.is_action_just_pressed("ui_right"):
		var marker_position_index = marker_positions.find(marker.rect_position)
		marker.rect_position = marker_positions[(marker_position_index + marker_positions.size() + 1) % marker_positions.size()]
		AudioEngine.play_effect("res://assets/audio/sfx/navigation/select_item.ogg")
	elif Input.is_action_just_pressed("ui_accept"):
		var upgrade = marker_locations[marker.rect_position]
		if GameState.has_enough_gold(upgrade.price()):
			if upgrade.charges != upgrade.max_charges:
				GameState.add_gold(-upgrade.price())
				GameState.game_state.upgrades[upgrade.upgrade_name] = GameState.game_state.upgrades[upgrade.upgrade_name] + 1
				GameState.send_changed()
				AudioEngine.play_effect("res://assets/audio/sfx/navigation/flag_on.ogg")
	
	var marker_position_index = marker_positions.find(marker.rect_position)
	var upgrade = upgrades[marker_position_index]
	# TODO clean
	$Description.text = upgrade.description_mapping[upgrade.upgrade_name]

	
