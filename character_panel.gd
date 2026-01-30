extends Control

signal pressed(item: Control)
signal pressed_right(item: Control)
signal pressed_middle(item: Control)

var channel_name = ""
var user_name = ""
var char_index = -1
var train_end_time = 0
var last_update_time = 0
var start_progress = 0.0
var resting = false
var rest_progress = 0
func load_data(data: Dictionary):
	$Top/Name.text = data['name']
	$TrainingProgress.value = data['progress']
	$RestProgress.value = data['progress2']
	rest_progress = data['progress2']
	$Top/Status.text = data['status']
	$Status1.text = data['text1']
	$Status2.text = data['text2']
	channel_name = data['channel']
	if channel_name == null:
		channel_name = ""
	char_index = data['idx']
	$ChannelUser.text = "%s: %s - %s" % [data['user'], int(data['idx']), channel_name]
	user_name = data['user']
	$Top/CharIndex.text = "%s" % [get_index()]
	$Rested.text = data['rest']
	resting = data['rest'] == "resting"
	if data['desync'] != null:
		if abs(data['desync']) > 60*2:
			var desync_text = Utils.format_seconds(data['desync'])
			if data['desync'] > 0:
				desync_text = "+" + desync_text
			$DesyncAmount.text = desync_text
		else:
			$DesyncAmount.text = ""
	else:
		$DesyncAmount.text = ""
	tooltip_text = data['tooltip']
	train_end_time = data['train_end_time']
	start_progress = data['progress']
	last_update_time = Time.get_unix_time_from_system()
	$ChannelColor.modulate = Color(data['color'])
	$StatusBorder.modulate = Color(data['status_color'])
	if data['status_color'] == "#000000":
		$StatusBorder.hide()
	else:
		$StatusBorder.show()

func load_user(user_name_: String):
	user_name = user_name_
	$ChannelUser.text = user_name_
	
var enabled = false
var filtered = false
func enable():
	enabled = true
	if not filtered:
		show()

func disable():
	enabled = false
	hide()
	
func filter_out():
	filtered = true
	hide()

func unfilter():
	filtered = false
	show()

func _ready() -> void:
	$Top/Name.text = ''
	$TrainingProgress.value = 0
	$RestProgress.value = 0
	$Top/Status.text = ''
	$Status1.text = ''
	$Status2.text = ''
	$Top/CharIndex.text = '..'
	$Rested.text = ''
	$DesyncAmount.text = ''
	$ChannelUser.text = user_name
	$StatusBorder.hide()
	$ChannelColor.modulate = Color(1,1,1,1)
	
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
		
var last_update = Time.get_ticks_msec() + randi_range(0, 500)
func _process(delta: float) -> void:
	var now = Time.get_ticks_msec()
	if now - last_update < 500:
		return
	last_update = now
	var t = Time.get_unix_time_from_system()
	if train_end_time < t:
		$TrainingProgress.value = 1
	else:
		var elapsed = t - last_update_time
		var total_remaining = (train_end_time - last_update_time)
		var increment = (elapsed / total_remaining) * (1 - start_progress)
		var current_progress = min(start_progress + increment, 1)
		$TrainingProgress.value = current_progress
	var rest_time = 2*60*60
	if rest_progress > 0 or rest_progress < 1:
		if resting:
			var remining_rest_time = (1-rest_progress) * (rest_time/2)
			var increment = (1-rest_progress) * (t-last_update_time) / remining_rest_time
			var current_progress = min(rest_progress + increment, 1)
			$RestProgress.value = current_progress
		else:
			var remining_rest_time = (1-rest_progress) * rest_time
			var increment = (1-rest_progress) * (t-last_update_time) / remining_rest_time
			var current_progress = max(rest_progress - increment, 0)
			$RestProgress.value = current_progress
