extends Control

var a_chat_message: RichTextLabel
var chat_message_pool: Array[RichTextLabel] = []
var pool_idx: int = 0
func _ready():
	%ChatMessage.hide()
	a_chat_message = %ChatMessage.duplicate()
	%ChatMessage.queue_free()

func recieve_system_message(text: String):
	recieve_chat_message("__sys", "__sys", "000000", text, false)

func recieve_chat_message(
	channel_name: String,
	user_name: String,
	user_color: String,
	text: String,
	me: bool
):
	var new_chat_message: RichTextLabel
	if len(chat_message_pool) < 200:
		new_chat_message = a_chat_message.duplicate()
		%ChatMessages.add_child(new_chat_message)
		chat_message_pool.append(new_chat_message)
	else:
		new_chat_message = chat_message_pool[pool_idx]
		%ChatMessages.move_child(new_chat_message, -1)
		pool_idx += 1
		pool_idx %= len(chat_message_pool)
	var message_format = "[color=999999]%s"
	if user_name != "__sys":
		message_format = "[color=ffffff7f]#%s [color=%s][b]%s[/b][color=white]"
		if me:
			message_format += " %s"
			text = "[color=cccccc][i]" + text + "[/i]"
		else:
			message_format += ": %s"
		new_chat_message.text = message_format % [channel_name, user_color, user_name, text]
	else:
		new_chat_message.text = message_format % text
	new_chat_message.show()
	var scroll = $ScrollContainer
	#print(len(chat_message_pool), ' ', pool_idx)
	if scroll.scroll_vertical > %ChatMessages.size.y - scroll.size.y - 150:
		await get_tree().process_frame
		scroll.ensure_control_visible(new_chat_message)
	
	


func _on_scroll_container_resized() -> void:
	pass # Replace with function body.
