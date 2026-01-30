extends HFlowContainer

var a_channel_panel: PanelContainer
func _ready():
	%ChannelPanel.hide()
	a_channel_panel = %ChannelPanel.duplicate()
	%ChannelPanel.queue_free()

var channel_panels: Dictionary[String, Control] = {}
func process_data(data: Array):
	for panel in channel_panels.values():
		panel.hide()
	for channel in data:
		var panel_key = "%s" % channel['id']
		if not panel_key in channel_panels:
			channel_panels[panel_key] = a_channel_panel.duplicate()
			add_child(channel_panels[panel_key])
			channel_panels[panel_key].show()
		var panel = channel_panels[panel_key]
		panel.show()
		panel.load_data(channel)
