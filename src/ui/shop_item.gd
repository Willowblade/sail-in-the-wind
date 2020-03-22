extends Control


onready var buy_price_label = $BuyPrice
onready var sell_price_label = $SellPrice
onready var icon = $InventoryIcon
onready var island_quantity_label = $IslandQuantity
onready var player_quantity_label = $PlayerQuantity

var properties = {}


func _ready():
	pass

	
func set_item(item: String):
	icon.set_contents(item)
	properties.name = item
	
func set_prices(buying_price: int, selling_price: int):
	buy_price_label.text = "-" + str(buying_price) + "g"
	properties.buy_price = buying_price
	sell_price_label.text = "+" + str(selling_price) + "g"
	properties.sell_price = selling_price

func update_quantity(island_quantity, player_quantity):
	if island_quantity > 9999:
		island_quantity_label.text = "Inf."
	else:
		island_quantity_label.text = str(island_quantity)
	properties.island_quantity = island_quantity
	properties.player_quantity = player_quantity
	
	player_quantity_label.text = str(player_quantity)
	

