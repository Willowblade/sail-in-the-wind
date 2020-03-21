extends KinematicBody2D
class_name Player

onready var sprite: AnimatedSprite = $Sprite
onready var waves: AnimatedSprite = $Waves


signal interact

var direction = Vector2(1, 0)


const MOVEMENT_SPEED: float = 50.0

var waves_max = false

var state = "IDLE"


func _ready():
	pass


func set_flip(velocity: Vector2):
	if velocity.x < 0:
		if sprite.flip_h == false:
			sprite.flip_h = true

	elif velocity.x > 0:
		if sprite.flip_h == true:
			sprite.flip_h = false
			
	else:
		if velocity.y != 0:
			sprite.flip_h = false
			
func set_animation(velocity: Vector2):	
	if velocity.x < 0:
		sprite.animation = "left-right"
		waves.show()
		if state != "HORIZONTAL_LEFT":
			state = "HORIZONTAL_LEFT"
			waves.animation = "horizontal"
			waves.frame = 0
			waves.position = Vector2(16, 0)
			waves.scale = Vector2(-1, 1)
		else:
			if waves.frame == 7:
				waves.animation = "horizontal_repeat"
	elif velocity.x > 0:
		sprite.animation = "left-right"
		waves.show()
		if state != "HORIZONTAL_RIGHT":
			state = "HORIZONTAL_RIGHT"
			waves.animation = "horizontal"
			waves.frame = 0
			waves.position = Vector2(-16, 0)
			waves.scale = Vector2(1, 1)
		else:
			if waves.frame == 7:
				waves.animation = "horizontal_repeat"
		
	elif velocity.y < 0:
		sprite.animation = "up"
		waves.show()
		if state != "VERTICAL_UP":
			state = "VERTICAL_UP"
			waves.animation = "vertical"
			waves.frame = 0
			waves.scale = Vector2(1, 1)
			waves.position = Vector2(0, 12)
		else:
			if waves.frame == 7:
				waves.animation = "vertical_repeat"

	elif velocity.y > 0:
		sprite.animation = "down"
		waves.show()
		if state != "VERTICAL_DOWN":
			state = "VERTICAL_DOWN"
			waves.animation = "vertical"
			waves.frame = 0
			waves.scale = Vector2(1, -1)
			waves.position = Vector2(0, -14)
		else:
			if waves.frame == 7:
				waves.animation = "vertical_repeat"
	else:
		state = "IDLE"
		waves.hide()
		
	

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
