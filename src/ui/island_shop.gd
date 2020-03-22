extends Control

onready var town_shop_label = $TownShopLabel
onready var marker = $Marker

var items_market = []
var current_island = null
var items = []
var marker_locations = {}
var marker_positions = []

onready var shop_item_scene = preload("res://src/ui/ShopItem.tscn")
onready var position = $Position2D

var has_upgrades = false


func _ready():
	GameState.connect("updated_game_state", self, "_on_updated_game_state")
	
	if GameState.DEBUG:
		pass
#		var island_scene = load("res://src/game/islands/TestIsland.tscn")
#		var island = island_scene.instance()
#		add_child(island)
#		island.resource_type = "Wood"
#		island.inventory = {
#			"wood": 99999,
#			"food": 50,
#			"metal": 0,
#		}
#
#		set_island(island)
		
		
#		set_items([{
#			"name": "wood",
#			"island_quantity": 99999,
#			"player_quantity": GameState.item_count("wood"),
#			"buy_price": 50,
#			"sell_price": 20,
#		},{
#			"name": "food",
#			"island_quantity": 99999,
#			"player_quantity": GameState.item_count("food"),
#			"buy_price": 20,
#			"sell_price": 20,
#		},{
#			"name": "metal",
#			"island_quantity": 0,
#			"player_quantity": GameState.item_count("metal"),
#			"buy_price": 1000,
#			"sell_price": 1000,
#		}])

func close():
	hide()

func _physics_process(delta):
	if not visible:
		return

	if marker_positions.size() == 0:
		return

	if Input.is_action_just_pressed("ui_focus_next"):
		if has_upgrades:
			UI.toggle_upgrades()
	if Input.is_action_just_pressed("ui_left"):
		var marker_position_index = marker_positions.find(marker.rect_position)
		marker.rect_position = marker_positions[(marker_position_index + marker_positions.size() - 1) % marker_positions.size()]
	elif Input.is_action_just_pressed("ui_right"):
		var marker_position_index = marker_positions.find(marker.rect_position)
		marker.rect_position = marker_positions[(marker_position_index + marker_positions.size() + 1) % marker_positions.size()]
	elif Input.is_action_just_pressed("ui_up"):
		var shop_item = marker_locations[marker.rect_position]
		var item_name = shop_item.properties.name
		if GameState.item_count(shop_item.properties.name) > 0:
			GameState.remove_item(item_name)
			GameState.add_gold(shop_item.properties.sell_price)
			current_island.inventory[item_name] = current_island.inventory.get(item_name, 0) + 1
			GameState.send_changed()
	elif Input.is_action_just_pressed("ui_down"):
		var shop_item = marker_locations[marker.rect_position]
		var item_name = shop_item.properties.name
		print(current_island.inventory)
		if current_island.inventory.get(item_name, 0) <= 0:
			return
		if GameState.has_enough_gold(shop_item.properties.buy_price):
			if GameState.has_inventory_space():
				GameState.add_gold(-shop_item.properties.buy_price)
				GameState.add_item(item_name)
				current_island.inventory[item_name] = current_island.inventory[item_name] - 1
				GameState.send_changed()

func make_items():
	if current_island == null:
		print("Big problem, trading with a null island?")
	var island_items = []
	for island_item in current_island.inventory:
		var price = current_island.get_prices(island_item)
		island_items.append({
			"name": island_item,
			"island_quantity": current_island.inventory[island_item],
			"player_quantity": 0,
			"buy_price": price.buy_price,
			"sell_price": price.sell_price,
		})
	
	var player_inventory = {}
	for item in GameState.game_state.inventory.contents:
		if not item in player_inventory:
			player_inventory[item] = GameState.item_count(item)
	for item in player_inventory:
		var found = false
		for island_item in island_items:
			if island_item.name == item:
				island_item.player_quantity = player_inventory[item]
				found = true
		if found:
			continue
		else:
			var price = current_island.get_prices(item)
			island_items.append({
				"name": item,
				"player_quantity": player_inventory[item],
				"island_quantity": current_island.inventory.get(item, 0),
				"buy_price": price.buy_price,
				"sell_price": price.sell_price,
			})
			
	return island_items
	
func _on_updated_game_state():
	if visible:
		update_items()
	
		
func create_shop_item():
	var shop_item = shop_item_scene.instance()
	add_child(shop_item)
	return shop_item
	
func set_items(items: Array):
	for market_item in items_market:
		market_item.queue_free()
	
	items_market = []
	
	var offset = -Vector2(96, 0) * 0.5 * (items.size() - 1)
	for i in range(items.size()):
		var item = items[i]
		var shop_item = create_shop_item()
		shop_item.rect_position = position.position + offset + i * Vector2(96, 0)
		shop_item.set_item(item.name)
		shop_item.set_prices(item.buy_price, item.sell_price)
		shop_item.update_quantity(item.island_quantity, item.player_quantity)
		items_market.append(shop_item)
	generate_marker_locations()

func generate_marker_locations():
	marker_positions = []
	marker_locations = {}
	for item in items_market:
		var location = item.rect_position - Vector2(32, 0) + Vector2(0, 8)
		marker_locations[location] = item
		marker_positions.append(location)
	marker.rect_position = marker_positions[0]
	
func update_items():
	print("Updating all this stuff!")
	items = make_items()
	# this is code working with a real island
	for i in range(items.size()):
		var item = items[i]
		var shop_item = items_market[i]
		shop_item.set_item(item.name)
		shop_item.set_prices(item.buy_price, item.sell_price)
		shop_item.update_quantity(item.island_quantity, item.player_quantity)
	
func set_island(island: Island):
	current_island = island
	set_island_name(island.island_name)
	items = make_items()
	set_items(items)
		

func set_island_name(island_name: String):
	town_shop_label.bbcode_text = "[center][u]Ye olde shoppe of " + island_name + "[/u][/center]"


func add_upgrades():
	has_upgrades = true

func remove_upgrades():
	has_upgrades = false
