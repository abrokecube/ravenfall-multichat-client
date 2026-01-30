extends ProgressBar

var start_ts = 0
var end_ts = 0
var label_text = "1x Exp"
var event_text = ""
var in_progress = false
var last_update = Time.get_ticks_msec()
func load_time(start_t: float, end_t: float, text: String, multiplier: int):
	start_ts = start_t
	end_ts = end_t
	if multiplier < 1:
		multiplier = 1
	label_text = "%sx Exp" % multiplier
	event_text = ""
	if multiplier > 1:
		event_text = text
		in_progress = true
	else:
		in_progress = false
		
func _process(delta: float) -> void:
	var t_m = Time.get_ticks_msec()
	if t_m - last_update < 500:
		return
	var out_text = label_text
	var length = end_ts - start_ts
	var t = Time.get_unix_time_from_system()
	var elapsed = min(t - start_ts, length)
	var remaining = max(end_ts - t, 0)
	var progress = 0
	if length > 0 and in_progress:
		progress = max(remaining / length, 0)
		out_text += " - %s - %s" % [Utils.format_seconds(remaining, Utils.TimeSize.SMALL_SPACES, 3), event_text]
	value = progress
	$Label.text = out_text
	last_update = Time.get_ticks_msec()

func _ready() -> void:
	value = 0
	$Label.text = "1x Exp"
