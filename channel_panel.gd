extends Control

signal pressed(item: Control)
signal pressed_right(item: Control)
signal pressed_middle(item: Control)

var channel_name = ""
func load_data(data: Dictionary):
	get_node('MarginContainer/HBoxContainer/ChannelIndex').text = "%s" % [get_index()]
	get_node("MarginContainer/HBoxContainer/ChannelName").text = data['display_name']
	get_node("MarginContainer/HBoxContainer/ChannelName/ChannelCategory").text = data['category']
	channel_name = data['name']
	$ChannelColor.modulate = Color(data['color'])
	tooltip_text = data['category']

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pressed.emit(self)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			pressed_right.emit(self)
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			pressed_middle.emit(self)

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		$Hilight.show()	
	if what == NOTIFICATION_MOUSE_EXIT:
		$Hilight.hide()
