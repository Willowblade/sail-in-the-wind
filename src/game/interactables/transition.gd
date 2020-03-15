extends Area2D
# should extend the interactable code but eh...
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var arrow = get_node("Arrow")

#export var destination: PackedScene
export var destination_path: String = "res://src/rooms/Room.tscn"
export var location: Vector2 = Vector2(0, 0)

var destination

var currently_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

	
func _on_body_entered(body: PhysicsBody2D):
	if body.get_name() == "Character":
		currently_active = true
		toggle_active()

func _on_body_exited(body: PhysicsBody2D):
	if body.get_name() == "Character":
		currently_active = false
		toggle_inactive()
		
func _on_player_interacted():
	if currently_active:
		perform_interaction()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func toggle_active():
	arrow.show()
	
func toggle_inactive():
	arrow.hide()

func perform_interaction():
	Transitions.transition_to_path(destination_path, location)


			

