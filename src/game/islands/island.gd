extends Node2D
class_name Island

onready var base = $Base
onready var area = $Area

var _cell_names = {}
var founded = false
var island_name = "Ol' Faithful"

export(String, "None", "Wood", "Metal", "Food") var resource_type = "Hello"

signal island_entered(island, body)
signal island_exited(island, body)


func _ready():
	var used_cells = base.get_used_cells()
	for cell in used_cells:
		var id = base.get_cell(cell[0], cell[1])
		var name = base.tile_set.tile_get_name(id)
		_cell_names[id] = name
	
	area.connect("body_entered", self, "_on_body_entered")
	area.connect("body_exited", self, "_on_body_exited")
	
func _on_body_entered(body):
	emit_signal("island_entered", self, body)
	
func _on_body_exited(body):
	emit_signal("island_exited", self, body)


func get_tile_at_position(coordinates: Vector2):
	var internal_coordinates = base.world_to_map(coordinates - position)
	var tile_id = base.get_cellv(internal_coordinates)
	return {
		"name": _cell_names[tile_id],
		"coordinates": base.map_to_world(internal_coordinates) + position,
	}
	
func has_tile_at_position(coordinates: Vector2):
	var internal_coordinates = base.world_to_map(coordinates - position)
	var tile_id = base.get_cellv(internal_coordinates)

	if tile_id != -1:
		return true
	return false
