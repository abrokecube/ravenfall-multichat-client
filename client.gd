extends Node

# The URL we will connect to.
var websocket_url = "ws://127.0.0.1:9832"

# Our WebSocketClient instance.
var socket = WebSocketPeer.new()
var connected = false

func set_connected(value: bool):
	if value == connected:
		return
	connected = value
	if value:
		call_deferred('message', 'connected')
	else:
		call_deferred('message', 'disconnected')

func reconnect():
	if connected:
		set_connected(false)
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")

func set_address(address: String):
	websocket_url = address
	if not websocket_url.contains('//'):
		websocket_url = "ws://" + websocket_url
	%addressEdit.text = websocket_url


func load_save_data():
	if not FileAccess.file_exists("user://data.json"):
		return
	var s = FileAccess.open("user://data.json", FileAccess.READ)
	var j_str = s.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(j_str)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", j_str, " at line ", json.get_error_line())
		return
	var data = json.data
	set_address(data.get('address', "ws://127.0.0.1:9832"))
		
func save_save_data():
	var s = FileAccess.open("user://data.json", FileAccess.WRITE)
	var data = {
		"address": websocket_url
	}
	s.store_line(JSON.stringify(data))
	
		
func _ready():
	load_save_data()
	%BottomStatus.text = "---"
	await reconnect()
	save_save_data()

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()

	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		set_connected(true)
		while socket.get_available_packet_count():
			var text = socket.get_packet().get_string_from_utf8()
			print("Got data from server: ", text)
			var json = JSON.new()
			var error = json.parse(text)
			if error == OK:
				var data = json.data
				match data['type']:
					"message":
						%Chat.recieve_chat_message(
							data['channel'],
							data['user'],
							data['user_color'],
							data['text'],
							data['me'],
						)
					"update_chars":
						%Characters.process_data(data['data'])
					"users":
						%Characters.prepare_panels(data['data'])
					"multiplier":
						%MultBar.load_time(
							data['start'],
							data['end'],
							data['event'],
							data['multiplier']
						)
					"channels":
						%Channels.process_data(data['data'])
					"update_desync":
						var desync_time = Utils.format_seconds(data['seconds'], Utils.TimeSize.SMALL_SPACES)
						if data['seconds'] > 0:
							desync_time = "+" + desync_time
						%BottomStatus.text = "Avg desync: %s" % desync_time
			

	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		set_connected(false)
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		await reconnect()


func _on_character_panel_pressed(item: Control) -> void:
	if len(item.user_name) > 0:
		%UserSelect.text = item.user_name
	if len(item.channel_name) > 0:
		%ChannelSelect.text = item.channel_name
	%ChatTextBox.grab_focus()
	
func _on_character_panel_pressed_right(item: Control) -> void:
	if len(item.user_name) > 0:
		%UserSelect.text = item.user_name
		%ChatTextBox.grab_focus()

func _on_channel_panel_pressed(item: Control) -> void:
	if len(item.channel_name) > 0:
		%ChannelSelect.text = item.channel_name
		%ChatTextBox.grab_focus()

func message(text):
	%Chat.recieve_system_message(text)

func handle_join(args: PackedStringArray):
	if len(args) == 0:
		message("Missing channel name.")
		return
	var out_text = JSON.stringify({
		"type": "join",
		"channel": args[0]
	})
	socket.send_text(out_text)

func handle_swap(args: PackedStringArray):
	var user = %UserSelect.text
	if len(user) < 3:
		message("Missing valid username in 'user' field.")
		return
	if len(args) < 2:
		message("/swap <index 1> <index 2>")
		return
	if not (args[0].is_valid_int() and args[1].is_valid_int()):
		message("One or both arguments are not integers")
	var index_1 = int(args[0])
	var index_2 = int(args[1])
	
	var char_a = null
	var char_b = null
	for char in %Characters.char_panels.values():
		if char.user_name == user:
			if char.char_index == index_1:
				char_a = char
			if char.char_index == index_2:
				char_b = char
		if char_a != null and char_b != null:
			break
			
	if not (char_a != null and char_b != null):
		message("One or both indexes don't exist")
		return
		
	var channel_a = char_a.channel_name
	var channel_b = char_b.channel_name

	send_message(user, channel_a, "!leave")
	await get_tree().create_timer(.52366).timeout
	send_message(user, channel_b, "!leave")
	await get_tree().create_timer(0.9225).timeout
	send_message(user, channel_a, "!join %s" % index_2)
	await get_tree().create_timer(1.123).timeout
	send_message(user, channel_b, "!join %s" % index_1)
	await get_tree().create_timer(.223).timeout
	message("Swap finished")

func handle_modall(args: PackedStringArray):
	if len(args) == 0:
		message("Include a user name")
		return
	var out_text = JSON.stringify({
		"type": "add_moderator",
		"user": args[0],
	})
	socket.send_text(out_text)

func send_message(user: String, channel: String, text: String):
	var out_text = JSON.stringify({
		"type": "send_message",
		"user": user,
		"channel": channel,
		"text": text
	})
	socket.send_text(out_text)

func send_command(cmd: String, args: PackedStringArray):
	var out_text = JSON.stringify({
		"type": "exec_command",
		"args": args,
	})

func parse_command(text: String):
	var args = text.split(" ")
	var command = args[0].substr(1)
	args = args.slice(1)
	match command:
		"join":
			handle_join(args)
		"swap":
			handle_swap(args)
		"modall":
			handle_modall(args)
		_:
			send_command(command, args)
			#message("Unknown command %s." % command)

func parse_chat_command(text: String):
	var args = text.split(" ")
	var command = args[0].substr(1)
	args = args.slice(1)
	match command:
		"join":
			pass
			
func _on_chat_text_box_text_submitted(text: String) -> void:
	if text[0] == "/":
		parse_command(text)
		return
	var user = %UserSelect.text
	var channel = %ChannelSelect.text
	if len(user) < 3 or len(channel) < 3:
		%Chat.recieve_system_message("Missing valid username or channel name.")
		return
	var out_text = JSON.stringify({
		"type": "send_message",
		"user": user,
		"channel": channel,
		"text": text
	})
	socket.send_text(out_text)
	
	if text[0] == "!":
		parse_chat_command(text)

var current_filter = ""
func _on_channel_panel_pressed_right(item: Control) -> void:
	var channel = item.channel_name.to_lower()
	if current_filter == channel:
		for panel in %Characters.char_panels.values():
			panel.unfilter()
		current_filter = ""
		return
	current_filter = channel
	for panel in %Characters.char_panels.values():
		panel.unfilter()
	for panel in %Characters.char_panels.values():
		if panel.channel_name.to_lower() != current_filter:
			panel.filter_out()


func _on_options_pressed() -> void:
	if %Settings.is_visible_in_tree():
		%Settings.hide()
	else:
		%Settings.show()


func _on_apply_pressed() -> void:
	set_address(%addressEdit.text)
	save_save_data()
	message("Applied changes")
	socket.close()
	set_process(true)
