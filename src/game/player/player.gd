extends KinematicBody2D
class_name Player

onready var sprite: AnimatedSprite = $Sprite


signal interact

var direction = Vector2(1, 0)


const MOVEMENT_SPEED: float = 50.0


func _ready():
	pass


func set_flip(velocity: Vector2):
	if velocity.x < 0:
		if sprite.flip_h == false:
			sprite.flip_h = true

	elif velocity.x > 0:
		if sprite.flip_h == true:
			sprite.flip_h = false
			
func set_animation(velocity: Vector2):
	if velocity.x != 0:
		sprite.animation = "left-right"
	elif velocity.y < 0:
		sprite.animation = "up"
	elif velocity.y > 0:
		sprite.animation = "down"

func set_direction(velocity: Vector2):
	if velocity.x > 0:
		direction = Vector2(1, 0)
	elif velocity.x < 0:
		direction = Vector2(-1, 0)
	elif velocity.y < 0:
		direction = Vector2(0, -1)
	elif velocity.y > 0:
		direction = Vector2(0, 1)
	
			
func _physics_process(delta):
	var velocity = Vector2(0, 0)
	var speed_factor = 1.0
	
	if Input.is_action_pressed("sprint"):
		speed_factor *= 2.0

	
	if Input.is_action_pressed("ui_left"):
		velocity.x -= MOVEMENT_SPEED * speed_factor
		
	if Input.is_action_pressed("ui_right"):
		velocity.x += MOVEMENT_SPEED * speed_factor
		
	if Input.is_action_pressed("ui_down"):
		velocity.y += MOVEMENT_SPEED * speed_factor
		
	if Input.is_action_pressed("ui_up"):
		velocity.y -= MOVEMENT_SPEED * speed_factor
		
	if Input.is_action_just_pressed("interact"):
		emit_signal("interact")
		
		
	if Input.is_action_just_pressed("debugging"):
		# GameState.grow()
		pass
		
	set_flip(velocity)
	set_animation(velocity)
	set_direction(velocity)
	
	move_and_collide(velocity * delta)
