extends Control


onready var marker = $Marker
var marker_positions = [Vector2(160, 240)]

onready var text = $Text

signal done

func _ready():
	marker.rect_position = marker_positions[0]
	set_physics_process(false)
#	activate()

func activate():
	set_text()

func _physics_process(delta):
	if not visible:
		return
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("done")

func set_text():
	var preamble = "[center]" + GameState.game_state.player.name + " of the Jerican Empire[/center]\n\n"
	var end = "Your ship '" + GameState.game_state.player.boat_name + "' is entirely at your disposal. Additionally, we have given you two piles of wood, two food rationings, five-hundred gold, and a lump of metal to kickstart your adventure."
	if GameState.all_islands_explored():
		pass
	else:
		text.bbcode_text = preamble + """We thank you for your many years of service ahead. A few words, however, on how this works.

Your men will need food, which they eat while sailing. Hard work makes hungry men. Buy that here in Jerico. In the Capital, you can also spend your hard-earned gold on 
[center][tornado radius=5 freq=3]Glorious Ship R&D[/tornado][/center].

Discovering an island will earn you money. Building a settlement on it, which requires some logs, earns you an additional well-earned sum of our treasury. You can trade resources with these settlements, including food!

""" + end
