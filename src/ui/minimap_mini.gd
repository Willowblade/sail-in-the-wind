extends Control

onready var minimap_label_scene = preload("res://src/ui/MinimapLabel.tscn")
onready var island_circles = $IslandCircles

var island_label_dict = {}
var island_labels = []

onready var labels = $Labels
var islands = []

func _ready():
	pass
	
func initialize_labels():
	islands = get_tree().get_nodes_in_group("island")
	island_labels = []
	for island in islands:
		var island_label = minimap_label_scene.instance()
		labels.add_child(island_label)
		island_labels.append(island_label)
		island_label_dict[island] = island_label
		
func load_islands(player):
	if island_labels.size() == 0:
		initialize_labels()
		
	island_circles.islands = islands
	island_circles.offset = player.position
	var capital_position = island_circles.get_capital_location()
	
	for island in islands:
		var island_label = island_label_dict[island]
		var difference = (island.position - player.position) / GameState.minimap_scale / 2
		var distance = difference.length()
		if distance > 62:
			island_label.hide()
		else:
			island_label.show() 
		
		
			if island.island_name == "" or island.island_name == "Tutorial Islands":
				island_label.hide()
#				island_label.text = ""
#				if abs(difference.x) > 80 or abs(difference.y) > 80:
#
#				else:
#					island_label.show() 
#				var circle_radius = (island.position - capital_position).length() / 400
#				var circle_location = island.position + circle_radius * island.map_offset - player.position
#				island_label.rect_position = labels.rect_position + (circle_location / (GameState.minimap_scale * 2))
			else:
				island_label.text = island.island_name
				island_label.rect_position = labels.rect_position + (island.position - player.position) / GameState.minimap_scale / 2 
		
	

		
	
		
		

		
