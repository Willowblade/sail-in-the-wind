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

var description_mapping = {
	"speed": "Increases your speed on the water",
	"inventory": "Increases the amount of material you can take along",
	"stamina": "Increases the quality of the food, thus making it last longer",
	"small_boat": "Unlocks a small cute rowing boat to sail up rivers",
}

func _ready():
	GameState.connect("updated_game_state", self, "_on_updated_game_state")
	_on_updated_game_state()
	
func _on_updated_game_state():
	charges = GameState.game_state.upgrades[upgrade_name]
	label.bbcode_text = "[center]" + string_mapping[upgrade_name] + "[/center]\n[center]" + str(charges) + "/" + str(max_charges) + "[/center]"

	set_price()

func price():
	return int(base_price + base_price * charges + sqrt(100 * charges))

func set_price():
	var price = price()
	if charges == max_charges:
		price_label.bbcode_text = "[center]Maxed![/center]"
	else:
		price_label.bbcode_text = "[center]Price: " + str(price) + "g[/center]"
