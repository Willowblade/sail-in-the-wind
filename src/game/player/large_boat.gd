extends Player
class_name LargeBoat

onready var raycasts = {
	"left": $Left,
	"right": $Right,
}

signal deploy_small_boat

func _ready():
	pass
	
func player_specific(delta):
	var raycasts_collide = raycasts.left.is_colliding() or raycasts.right.is_colliding()
	if Input.is_action_just_pressed("ui_select"):
		if raycasts_collide:
			pass
		else:
			if GameState.game_state.upgrades.small_boat == 1:
				emit_signal("deploy_small_boat")
