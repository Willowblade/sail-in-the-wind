extends Control


onready var frame_scene = preload("res://src/ui/InventoryIcon.tscn")

var inventory_space = 3
var contents = ["wood", "food", "metal"]


func _ready():
	set_frames()
	set_contents()
	
func has_item(item: String):
	contents.count(item)
	
func add_item(item: String):
	if contents.size() < inventory_space:
		contents.append(item)
	
func create_frame():
	var frame = frame_scene.instance()
	add_child(frame)
	return frame
	
func set_frames():
	print(rect_position)
	var i = 0
	for space in inventory_space:
		var frame = create_frame()
		frame.rect_position = rect_position + i * Vector2(0, 60)
		i += 1
		
func set_contents():
	var frames = get_children()
	for i in range(contents.size()):
		var frame = frames[i]
		frame.set_contents((contents[i]))
	
