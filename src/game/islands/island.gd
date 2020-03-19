extends Node2D
class_name Island

onready var base = $Base
onready var contents = $Contents
onready var area = $Area

var _base_cell_names = {}
var _contents_cell_names = {}
var founded = false

export(String, "None", "Wood", "Metal", "Food") var resource_type = "None"
export var island_name = ""

signal island_entered(island, body)
signal island_exited(island, body)


func _ready():
	_base_cell_names = get_tile_mapping(base)
	_contents_cell_names = get_tile_mapping(contents)
	
	area.connect("body_entered", self, "_on_body_entered")
	area.connect("body_exited", self, "_on_body_exited")


func get_tile_mapping(tilemap: TileMap) -> Dictionary:
	var mapping = {}
	var used_cells = base.get_used_cells()
	for cell in used_cells:
		var id = base.get_cell(cell[0], cell[1])
		var name = base.tile_set.tile_get_name(id)
		_base_cell_names[id] = name
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
	
func has_tile_at_position(coordinates: Vector2):
	var tile_id = _get_tile_id(coordinates, base)

	if tile_id != -1:
		return true
	return false


func tile_is_occupied(coordinates: Vector2):
	var tile_id = _get_tile_id(coordinates, contents)

	if tile_id != -1:
		return true
	return false


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
	founded = true
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
