extends Control


onready var marker = $Marker
var marker_positions = [Vector2(160, 240)]

onready var text = $Text

signal done

func _ready():
	marker.rect_position = marker_positions[0]
#	activate()

func activate():
	set_text()

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("done")

func set_text():
	var preamble = "[center]" + GameState.game_state.player.name + " of the empire[/center]\n\n"
	var end = "We've rebuilt your ship '" + GameState.game_state.player.boat_name + "' and have given you two piles of wood, two food rationings, and five-hundred gold to kickstart your newest venture. Hopefully carelessness does not overcome you so quickly again. Sign this document to continue."
	if GameState.all_islands_explored():
		pass
	else:
		text.bbcode_text = preamble + """You idiot! What gives? Did you forget your role in the progress of our Great Nation?

With the necromantic arts at our disposal, we were able to bring you back. Sailing this boat and discovering will be your eternal curse, but try to die as few times as possible... Necromancy isn't cheap.

""" + end
