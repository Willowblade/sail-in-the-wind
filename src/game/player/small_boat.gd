extends Player
class_name SmallBoat

onready var area = $BoatDetectionArea

var in_boat_range = false

signal return_small_boat

func _ready():
	area.connect("body_entered", self, "_on_body_entered")
	area.connect("body_exited", self, "_on_body_exited")
	
func _on_body_entered(body):
	if body is LargeBoat:
		in_boat_range = true
		print("Large boat entered")

func _on_body_exited(body):
	if body is LargeBoat:
		in_boat_range = false
		print("Large boat exited")
		
func player_specific(delta):
	if Input.is_action_just_pressed("ui_select"):
		if in_boat_range:
			emit_signal("return_small_boat")
