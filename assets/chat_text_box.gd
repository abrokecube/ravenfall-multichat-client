extends TextEdit

var text_history: Array[String] = []
var text_draft: String = ""
var history_pos: int = 0
signal text_submitted(text: String)
func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			get_viewport().set_input_as_handled()
			if not event.echo:
				if not event.shift_pressed:
					if len(text) > 0:
						text_submitted.emit(text)
						if len(text_history) > 0:
							if text_history[-1] != text:
								text_history.append(text)
						else:
							text_history.append(text)
						history_pos = 0
					text = ""
					text_draft = ""
				else:
					insert_text_at_caret("\n")
		elif event.keycode == KEY_DOWN:
			get_viewport().set_input_as_handled()
			if history_pos < 0:
				history_pos += 1
			if history_pos == 0:
				text = text_draft
				set_caret_column(len(text))
			else:
				text = text_history[history_pos]
				set_caret_column(len(text))
		elif event.keycode == KEY_UP:
			get_viewport().set_input_as_handled()
			if -history_pos >= len(text_history):
				return
			history_pos -= 1
			if history_pos == -1:
				text_draft = text
			text = text_history[history_pos]
			set_caret_column(len(text))
