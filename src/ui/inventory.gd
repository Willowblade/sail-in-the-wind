extends Control


onready var frame_scene = preload("res://src/ui/InventoryIcon.tscn")


var frame_count = 0
var frames = []

func _ready():
	set_frames()
	set_contents()
	GameState.connect("updated_game_state", self, "on_updated_game_state")
	
func get_contents() -> Array:
	return GameState.game_state.inventory.contents

func get_space() -> Array:
	return GameState.game_state.inventory.space

func on_updated_game_state():
	var new_frames = get_space()
	if new_frames != frame_count:
		frame_count = new_frames
		set_frames()
	set_contents()
	
func create_frame():
	var frame = frame_scene.instance()
	add_child(frame)
	return frame
	
func set_frames():
	for frame in frames:
#		remove_child(frame)
		frame.queue_free()

	frames = []
	var space = get_space()
	var offset = -Vector2(52, 0) * 0.5 * (space - 1)
	for i in range(space):
		var frame = create_frame()
		frame.rect_position = rect_position + offset + i * Vector2(52, 0)
		frames.append(frame)
		
func set_contents():
	var contents = get_contents()
	for frame in frames:
		frame.clear_contents()

	for i in range(min(contents.size(), frames.size())):
		var frame = frames[i]
		frame.set_contents((contents[i]))
	
