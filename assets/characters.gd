extends HFlowContainer

var a_character_panel: Control
func _ready():
	%CharacterPanel.hide()
	a_character_panel = %CharacterPanel.duplicate()
	%CharacterPanel.queue_free()

var char_panels: Dictionary[String, Control] = {}
func prepare_panels(data: Array):
	for panel in char_panels.values():
		panel.disable()
	for user_name in data:
		for x in range(1,4):
			var panel_key = "%s_%s" % [user_name, x]
			if not panel_key in char_panels:
				char_panels[panel_key] = a_character_panel.duplicate()
				char_panels[panel_key].load_user(user_name)
				add_child(char_panels[panel_key])
			char_panels[panel_key].enable()
	
func process_data(data: Array):
	for character in data:
		var panel_key = "%s_%s" % [character['user'], int(character['idx'])]
		if not panel_key in char_panels:
			continue
		var panel = char_panels[panel_key]
		panel.enable()
		panel.load_data(character)
