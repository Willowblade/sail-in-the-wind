extends Node2D
class_name Island

onready var base = $Base
onready var contents = $Contents
onready var area = $Area
onready var coast = $AnimatedCoasts

var _base_cell_names = {}
# this mapping isn't used right now?
var _contents_cell_names = {}
var settled = false
var inventory = {}
var level = 1
# how to solve this little issue? Timer to increase gold?
var gold = 0
# is to be expanded...
var needed = {}

var discovered_by = ""

export var capital: bool = false
export(String, "None", "Wood", "Metal", "Food") var resource_type = "None"
export(String, "None", "Wood", "Metal", "Food") var second_resource_type = "None"
export(String, FILE, "*.ogg") var audio_track = ""
export var island_name = ""
export (String, MULTILINE) var description = ""

var map_offset

signal island_entered(island, body)
signal island_exited(island, body)


const ECONOMY = {
	"food": 50,
	"wood": 200,
	"metal": 600,
}


func _ready():
	map_offset = Vector2(randf() - 0.5, randf() - 0.5)
	if capital:
		settled = true
	if island_name == "Tutorial Islands":
		settled = true
	_base_cell_names = get_tile_mapping(base)
	_contents_cell_names = get_tile_mapping(contents)

	if capital:
		inventory = {
			"food": 99999,
			"wood": 99999,
			"metal": 99999,

		}
	else:

		for resource in ["wood", "food", "metal"]:
			if resource_type.to_lower() == resource:
				inventory[resource] = 99999
			elif second_resource_type.to_lower() == resource:
				inventory[resource] = 99999
			else:
				inventory[resource] = 0 
	
	area.connect("body_entered", self, "_on_body_entered")
	area.connect("body_exited", self, "_on_body_exited")


func get_prices(item_name: String):
	var sell_modifier = 1.0
	var buy_modifier = 1.0
	if item_name == resource_type.to_lower():
		sell_modifier = 0.3
		buy_modifier = 0.5
	elif item_name == second_resource_type.to_lower():
		sell_modifier = 0.45
		buy_modifier = 0.6
	else:
		buy_modifier = 3.0
		sell_modifier = 2.0
	
	if capital:
		sell_modifier = 0.8
		buy_modifier = 0.8

	return {
		"buy_price": int(1.0 / sqrt(level) * ECONOMY[item_name] * buy_modifier),
		"sell_price": int(1.0 / sqrt(level) * ECONOMY[item_name] * sell_modifier)
	}

func get_tile_mapping(tilemap: TileMap) -> Dictionary:
	var mapping = {}
	var used_cells = tilemap.get_used_cells()
	for cell in used_cells:
		var id = tilemap.get_cell(cell[0], cell[1])
		var name = tilemap.tile_set.tile_get_name(id)
		mapping[id] = name
	return mapping


func _on_body_entered(body):
	emit_signal("island_entered", self, body)
	
func _on_body_exited(body):
	emit_signal("island_exited", self, body)


func get_tile_at_position(coordinates: Vector2):
	var internal_coordinates = base.world_to_map(coordinates - position)
	var tile_id = base.get_cellv(internal_coordinates)
	return {
		"name": _base_cell_names[tile_id],
		"coordinates": base.map_to_world(internal_coordinates) + position,
	}
	
func has_island_tile_at_position(coordinates: Vector2):
	var tile_id = _get_tile_id(coordinates, base)

	if tile_id != -1:
		return true
	return false


func tile_is_occupied(coordinates: Vector2):
	var tile_id = _get_tile_id(coordinates, contents)

	if tile_id != -1:
		return true
	return false

func tile_is_coast(coordinates: Vector2):
	var tile_id = _get_tile_id(coordinates, coast)

	if tile_id != -1:
		return true
	return false


func get_contents_tile(coordinates: Vector2):
	var internal_coordinates = contents.world_to_map(coordinates - position)
	var tile_id = _get_tile_id(coordinates, contents)
	return {
		"tile_id": tile_id,
		"tile_name": contents.tile_set.tile_get_name(tile_id),
		"coordinates": contents.map_to_world(internal_coordinates) + position,
	}

func get_coast_tile(coordinates: Vector2):
	var internal_coordinates = coast.world_to_map(coordinates - position)
	return {
		"coordinates": coast.map_to_world(internal_coordinates) + position,
	}

func _get_tile_id(world_coordinates: Vector2, tilemap: TileMap) -> int:
	var internal_coordinates = tilemap.world_to_map(world_coordinates - position)
	var tile_id = tilemap.get_cellv(internal_coordinates)
	return tile_id

func get_settlement_tile_id():
	if resource_type == "None":
		print("ERROR: island ", name, " has no resource type!")
		return contents.tile_set.find_tile_by_name("wood_settlement_large")
	if resource_type == "Food":
		return contents.tile_set.find_tile_by_name("food_settlement_large")
	if resource_type == "Wood":
		return contents.tile_set.find_tile_by_name("wood_settlement_large")
	if resource_type == "Metal":
		return contents.tile_set.find_tile_by_name("metal_settlement_large")

func settle(tiles: Dictionary):
	settled = true
	var harbor_tile_id = contents.tile_set.find_tile_by_name("harbor")
	var settlement_tile_id = get_settlement_tile_id()
	var harbor_coordinate = contents.world_to_map(tiles["coast"]["coordinates"] - position)

	if tiles.direction == Vector2(0, 1):
		contents.set_cell(harbor_coordinate.x, harbor_coordinate.y, harbor_tile_id, false, true)
	elif tiles.direction == Vector2(0, -1):
		contents.set_cell(harbor_coordinate.x, harbor_coordinate.y, harbor_tile_id, false, false)
	elif tiles.direction == Vector2(1, 0):
		contents.set_cell(harbor_coordinate.x, harbor_coordinate.y, harbor_tile_id, true, false, true)
	elif tiles.direction == Vector2(-1, 0):
		contents.set_cell(harbor_coordinate.x, harbor_coordinate.y, harbor_tile_id, false, false, true)		
		
	var town_coordinate = contents.world_to_map(tiles["land"]["coordinates"] - position)
	contents.set_cell(town_coordinate.x, town_coordinate.y, settlement_tile_id)
