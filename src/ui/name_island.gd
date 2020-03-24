extends Control


onready var name_edit = $Name

onready var marker = $Marker
var marker_positions = [Vector2(-80, 240), Vector2(160, 240)]

signal done(contents)

func _ready():
	marker.rect_position = marker_positions[0]
	name_edit.grab_focus()
	$Confirm.hide()
	
func activate():
	name_edit.grab_focus()
	
func set_island(island: Island):
	$Text.bbcode_text = """[center]Loyal servant of the Jerican Empire[/center]

Well done. When I receive this letter by eagle mail, I will assume you have discovered a new island. Send me its name, its coordinates, and its description, and I will instruct the Royal Cartographer to update all of our maps. You will of course also receive what is due. 300 gold will be indebted to you at my earliest convenience.

""" 
	$Text.bbcode_text += "Description: " + island.description
	
func _physics_process(delta):
	if not visible:
		return
		
	if Input.is_action_just_pressed("ui_focus_next"):
		var marker_position_index = marker_positions.find(marker.rect_position)
		marker.rect_position = marker_positions[(marker_position_index + 1) % marker_positions.size()]
		if marker.rect_position == marker_positions[0]:
			name_edit.grab_focus()
			$Confirm.hide()
		elif marker.rect_position == marker_positions[1]:
			name_edit.grab_focus()
			$Confirm.show()
	if Input.is_action_just_pressed("ui_accept"):
		if marker.rect_position == marker_positions[0]:
			name_edit.grab_focus()
		elif marker.rect_position == marker_positions[1]:
			var name_edit_text = name_edit.text
			if name_edit_text == "":
				print("Empty name")
			else:
				emit_signal("done", {
					"name": name_edit.text,
				})
			

func set_text():
	pass

