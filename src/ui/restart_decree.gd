extends Control


onready var marker = $Marker
var marker_positions = [Vector2(160, 240)]

onready var text = $Text

signal done

func _ready():
	marker.rect_position = marker_positions[0]
	set_physics_process(false)

func activate():
	pass

func _physics_process(delta):
	if not visible:
		return
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("done")

