extends KinematicBody2D


onready var sprite: AnimatedSprite = get_node("Sprite")


signal interact

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var movement_speed: float = 200.0
# Called when the node enters the scene tree for the first time.

func _ready():
	pass


func set_flip(velocity: Vector2):
	if velocity.x < 0:
		if sprite.flip_h == false:
			sprite.flip_h = true

	elif sprite.x > 0:
		if sprite.flip_h == true:
			sprite.flip_h = false
			
func set_animation(velocity: Vector2):
	if velocity.x == 0 and velocity.y == 0:
		sprite.animation = "idle"
	else:
		if Input.is_action_pressed("sprint"):
			sprite.animation = "run"
		else:
			sprite.animation = "walk"
			
func _physics_process(delta):
	var velocity = Vector2(0, 0)
	var speed_factor = 1.0
	
	if Input.is_action_pressed("sprint"):
		speed_factor *= 2.0

	
	if Input.is_action_pressed("ui_left"):
		velocity.x -= movement_speed * speed_factor
		
	if Input.is_action_pressed("ui_right"):
		velocity.x += movement_speed * speed_factor
		
	if Input.is_action_pressed("ui_down"):
		velocity.y += movement_speed * speed_factor
		
	if Input.is_action_pressed("ui_up"):
		velocity.y -= movement_speed * speed_factor
		
	if Input.is_action_just_pressed("interact"):
		emit_signal("interact")
		
		
	if Input.is_action_just_pressed("debugging"):
		GameState.grow()
		
	set_flip(velocity)
	set_animation(velocity)
		
	move_and_slide(velocity, Vector2(0, -1))
