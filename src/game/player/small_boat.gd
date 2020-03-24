extends Player
class_name SmallBoat

onready var area = $BoatDetectionArea

var in_boat_range = false

signal return_small_boat
signal in_large_boat_area(is_near_large_boat)

func _ready():
	area.connect("body_entered", self, "_on_body_entered")
	area.connect("body_exited", self, "_on_body_exited")
	connect("in_large_boat_area", UI, "_on_near_large_boat")
	
func _on_body_entered(body):
	if body is LargeBoat:
		in_boat_range = true
		print("Large boat entered")
		emit_signal("in_large_boat_area", true)

func _on_body_exited(body):
	if body is LargeBoat:
		in_boat_range = false
		print("Large boat exited")
		emit_signal("in_large_boat_area", false)
		
func player_specific(delta):
	if Input.is_action_just_pressed("ui_select"):
		if in_boat_range:
			emit_signal("return_small_boat")
