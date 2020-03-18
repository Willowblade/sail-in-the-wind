extends WindowDialog

onready var line_edit = $LineEdit
onready var label = $Label
onready var button = $Button

func _ready():
	button.disabled = true
	line_edit.connect("text_changed", self, "_on_line_edit_text_changed")
	button.connect("pressed", self, "_on_button_name_pressed")
	
	connect("about_to_show", self, "_on_about_to_show")
	connect("popup_hide", self, "on_popup_hide")
	
func _on_line_edit_text_changed(new_value: String):
	if new_value.strip_edges() != "":
		button.disabled = false
	else:
		button.disabled = true
		
func _on_button_name_pressed():
	hide()

	
func _on_about_to_show():
	print("About to show")
	
func on_popup_hide():
	print("About to hide")
	

		

