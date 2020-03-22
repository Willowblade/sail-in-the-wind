extends Node

var game_state = {
	"gold": 100,
	"player": {
		# "name": "Testyman",
		# "boat_name": "My main boaty!",
	},
	"inventory": {
		"space": 6,
		"contents": ["food", "wood", "metal"]
	},
	"upgrades": {
		"speed": 0,
		"stamina": 0,
		"inventory": 0,
		"small_boat": 0,
	}
}

var DEBUG = true

signal updated_game_state(game_state)
	

func has_inventory_space():
	return game_state.inventory.contents.size() < game_state.inventory.space

func add_item(item: String):
	var contents = game_state.inventory.contents
	var space = game_state.inventory.space
	if contents.size() < space:
		contents.append(item)
	send_changed()

func remove_item(item: String):
	var contents = game_state.inventory.contents
	var index = contents.find_last(item)
	if index == -1:
		send_changed()
		return false
	else:
		contents.remove(index)
		print(contents)
		send_changed()
		return true

func add_inventory_space(increase):
	game_state.inventory.space = min(max(0, game_state.inventory.space + increase), 12)
	send_changed()

func has_item(item: String, count: int) -> bool:
	var item_count = game_state.inventory.contents.count(item)
	if item_count < count:
		return false
	return true
	
func item_count(item: String):
	return game_state.inventory.contents.count(item)

func add_gold(increase: int):
	game_state.gold = max(0, game_state.gold + increase)
	send_changed()

func has_enough_gold(gold: int):
	return game_state.gold >= gold

func send_changed():
	emit_signal("updated_game_state")

func _ready():
	AudioEngine.set_master_volume(0.6)


func get_save_game_data():
	pass
	

func load_game():
	pass
