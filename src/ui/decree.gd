extends Control


onready var name_edit = $Name
onready var boat_name_edit = $BoatName

onready var marker = $Marker
var marker_positions = [Vector2(-320, 240), Vector2(-80, 240), Vector2(160, 240)]

signal done(contents)

func _ready():
	marker.rect_position = marker_positions[0]
	name_edit.grab_focus()
	
func activate():
	name_edit.grab_focus()
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_focus_next"):
		var marker_position_index = marker_positions.find(marker.rect_position)
		marker.rect_position = marker_positions[(marker_position_index + 1) % marker_positions.size()]
		if marker.rect_position == marker_positions[0]:
			name_edit.grab_focus()
		elif marker.rect_position == marker_positions[1]:
			boat_name_edit.grab_focus()
		else:
			boat_name_edit.grab_focus()
	if Input.is_action_just_pressed("ui_accept"):
		if marker.rect_position == marker_positions[0]:

			name_edit.grab_focus()
		elif marker.rect_position == marker_positions[1]:
			boat_name_edit.grab_focus()
		elif marker.rect_position == marker_positions[2]:
			if name_edit.text == "":
				print("Empty name")
			else:
				var boat_name = boat_name_edit.text
				if boat_name == "":
					boat_name = "I'm A Boat!"
				emit_signal("done", {
					"name": name_edit.text,
					"boat_name": boat_name,
				})
			

func set_text():
	pass
