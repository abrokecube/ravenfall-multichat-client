extends Node
enum TimeSize {SMALL, SMALL_SPACES, MEDIUM, MEDIUM_SPACES, LONG}

var _time_str = {
	'day': ['d', 'd', 'day', ' day', ' day'],
	'days': ['d', 'd', 'days', ' days', ' days'],
	'hour': ['h', 'h', 'hr', ' hr', ' hour'],
	'hours': ['h', 'h', 'hrs', ' hrs', ' hours'],
	'minute': ['m', 'm', 'min', ' min', ' minute'],
	'minutes': ['m', 'm', 'mins', ' mins', ' minutes'],
	'second': ['s', 's', 'sec', ' sec', ' second'],
	'seconds': ['s', 's', 'secs', ' secs', ' seconds'],
}

func format_seconds(seconds: int, size=TimeSize.SMALL, max_terms=99, include_zero=true):
	seconds = int(seconds)
	var total_seconds = seconds
	var negative = false
	if seconds < 0:
		seconds = -seconds
		negative = true
	var days = seconds / 86400
	seconds %= 86400
	var hours = seconds / 3600
	seconds %= 3600
	var minutes = seconds / 60
	seconds %= 60
	
	var parts = []
	var word
	if days:
		word = _time_str['day'][size] if days == 1 else _time_str['days'][size]
		parts.append("%s%s" % [days, word])
	if hours or (include_zero and days):
		word = _time_str['hour'][size] if hours == 1 else _time_str['hours'][size]
		parts.append("%s%s" % [hours, word])
	if minutes or (include_zero and hours or days):
		word = _time_str['minute'][size] if minutes == 1 else _time_str['minutes'][size]
		parts.append("%s%s" % [minutes, word])
	if seconds or (include_zero and minutes or hours or days) or not parts:
		word = _time_str['second'][size] if seconds == 1 else _time_str['seconds'][size]
		parts.append("%s%s" % [seconds, word])
	if size == TimeSize.LONG and len(parts) > 1:
		# parts[-1] = "and " + parts[-1]
		# bye oxford comma
		var last = parts.pop()
		parts[-1] += " and %s" % last
	parts = parts.slice(0, max_terms)
	
	if negative:
		parts[0] = "-%s" % parts[0]
	
	if size == TimeSize.LONG:
		return ", ".join(parts).strip_edges()
	elif size in [TimeSize.MEDIUM, TimeSize.MEDIUM_SPACES, TimeSize.SMALL_SPACES]:
		return " ".join(parts).strip_edges()
	else:
		return "".join(parts).strip_edges()
