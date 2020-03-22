extends Control

onready var image = $Image
onready var label = $Description
onready var price_label = $Price

export(String, "speed", "inventory", "stamina", "small_boat") var upgrade_name = "inventory"
export var base_price = 100
export var max_charges = 1
var charges = 0

var string_mapping = {
	"speed": "Sail speed",
	"inventory": "Hull space",
	"stamina": "Food preservation",
	"small_boat": "Rowing boat",
}

func _ready():
	GameState.connect("updated_game_state", self, "_on_updated_game_state")
	_on_updated_game_state()
	
func _on_updated_game_state():
	charges = GameState.game_state.upgrades[upgrade_name]
	label.bbcode_text = "[center]" + string_mapping[upgrade_name] + "[/center]\n[center]" + str(charges) + "/" + str(max_charges) + "[/center]"

	set_price()

func price():
	return base_price + base_price / 2 * charges

func set_price():
	var price = price()
	price_label.bbcode_text = "[center]Price: " + str(price) + "g[/center]"
