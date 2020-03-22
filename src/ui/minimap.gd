extends Control

onready var minimap_label_scene = preload("res://src/ui/MinimapLabel.tscn")
onready var island_circles = $IslandCircles

var island_label_dict = {}
var island_labels = []

onready var labels = $Labels

func _ready():
	pass
	
func load_islands(player):
	for island_label in island_labels:
		labels.remove_child(island_label)
		island_label.queue_free()
	
	island_labels = []
	
	var islands = get_tree().get_nodes_in_group("island")
	island_circles.islands = islands
	island_circles.offset = player.position
	var capital_position = island_circles.get_capital_location()
	
	for island in islands:
		var island_label = minimap_label_scene.instance()
		labels.add_child(island_label)
		print("Island!", island.name)
		if island.island_name == "":
			island_label.text = "?"
			var circle_radius = (island.position - capital_position).length() / 100
			var circle_location = island.position + circle_radius * island.map_offset - player.position
			island_label.rect_position = labels.rect_position + (circle_location / GameState.minimap_scale)
		else:
			island_label.text = island.island_name
			island_label.rect_position = labels.rect_position + (island.position - player.position) / GameState.minimap_scale 
		island_labels.append(island_label)
		island_label_dict[island] = island_label
		
	

		
	
		
		

		
