extends Node2D


var offset: Vector2 = Vector2(0, 0)
var islands = []

func _ready():
	pass

func _process(delta):
	if visible:
		update()
		
func get_capital_location() -> Vector2:
	for island in islands:
		if island.capital:
			return island.position
	return Vector2(0, 0)
	
		
func _draw():
	draw_circle(Vector2(0, 0), 5, Color(0, 0, 0, 1))
	# draws the islands
	var capital_location = get_capital_location()
	
	for island in islands:
		# unknown island
		if island.island_name == "":
			var circle_radius = (island.position - capital_location).length() / 100
			var circle_location = island.position + circle_radius * island.map_offset - offset
			draw_circle(circle_location / GameState.minimap_scale, circle_radius, Color(1, 0.5, 0, 0.6))
		else:
			draw_circle((island.position - offset) / GameState.minimap_scale, 3, Color(0, 0, 0, 1))
	
