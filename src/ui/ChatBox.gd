extends Node

onready var chatBox = get_node("ChatBox")
onready var chatLog = get_node("ChatBox/VBoxContainer/RichTextLabel")
onready var inputLabel = get_node("ChatBox/VBoxContainer/HBoxContainer/Label")
onready var inputField = get_node("ChatBox/VBoxContainer/HBoxContainer/LineEdit")

var groups = [
	{'name': 'All', 'color': '#ffffff'},
	{'name': 'Team', 'color': '#34c5f1'}
]
var system_color = '#f1c234'
var response_color = '#ffffff'
var group_index = 0

var username = "Player"
var enabled = true

func set_username(name):
	username = name

func set_enabled(b):
	chatBox.visible = b
	enabled = b
	if not b:
		inputField.release_focus()

func _ready():
	inputField.connect("text_entered", self, "text_entered")
	change_group(0)
	set_enabled(false)

func _input(event):
	if event is InputEventKey and enabled:
		if event.pressed and event.scancode == KEY_ENTER:
			if inputField.has_focus() and len(inputField.text) == 0:
				inputField.release_focus()
			else:
				inputField.grab_focus()
		if event.pressed and event.scancode == KEY_ESCAPE:
			inputField.text = ''
			inputField.release_focus()
		if event.pressed and event.scancode == KEY_TAB:
			if inputField.has_focus():
				change_group(1)

func change_group(value):
	group_index += value
	if group_index > (groups.size() - 1):
		group_index = 0
	inputLabel.text = '[' + groups[group_index]['name'] +']'
	inputLabel.set('custom_colors/font_color', Color(groups[group_index]['color']))

func add_message(_username, text, group = 0, remote_msg = false):
	if len(text) > 0:
		chatLog.bbcode_text += '[color=' + groups[group]['color'] +']'
		chatLog.bbcode_text += '[' + _username + ']: '
		chatLog.bbcode_text += text
		chatLog.bbcode_text += '[/color]'
		chatLog.bbcode_text += '\n'
		
		if not remote_msg:
			rpc_unreliable("n_add_message", username, text, group)

remote func n_add_message(_username, text, group):
	add_message(_username, text, group, true)

func add_system_message(text):
	if len(text) > 0:
		chatLog.bbcode_text += '[color=' + system_color +']'
		chatLog.bbcode_text += text
		chatLog.bbcode_text += '[/color]'
		chatLog.bbcode_text += '\n'

func add_command_message(text1, text2):
	if len(text1) > 0 and len(text2) > 0:
		chatLog.bbcode_text += '[color=' + system_color +']'
		chatLog.bbcode_text += text1
		chatLog.bbcode_text += '[/color]'
		chatLog.bbcode_text += '[color=' + response_color +']'
		chatLog.bbcode_text += text2
		chatLog.bbcode_text += '[/color]'
		chatLog.bbcode_text += '\n'

func text_entered(text):
	if text.left(1) == "/":
		var res = Commands.process_command(text.substr(1))
		add_command_message(res[0], res[1])
	else:
		add_message(username, text, group_index)
	inputField.text = ''
	if len(text) > 0:
		inputField.release_focus()
