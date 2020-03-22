extends Control

onready var bar = $ConsumptionBar/Bar

var food_level = 1.0

signal food_empty

func _ready():
	pause()
	
func renew_food():
	food_level = 1.0
	
func _physics_process(delta: float):
	var rate = GameState.get_food_rate()
	food_level -= rate * delta
	if food_level <= 0.0:
		if GameState.has_item("food", 1):
			GameState.remove_item("food")
			renew_food()
			update_bar()
		else:
			emit_signal("food_empty")
	
func update_bar():
	bar.scale.y = - food_level * 3

func pause():
	set_process(false)
	
func play():
	set_process(true)
