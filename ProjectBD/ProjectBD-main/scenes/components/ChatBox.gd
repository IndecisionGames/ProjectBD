extends Control

onready var chatLog = get_node("VBoxContainer/RichTextLabel")
onready var inputLabel = get_node("VBoxContainer/HBoxContainer/Label")
onready var inputField = get_node("VBoxContainer/HBoxContainer/LineEdit")

var groups = [
	{'name': 'All', 'color': '#ffffff'},
	{'name': 'Team', 'color': '#34c5f1'}
]
var system_color = '#f1c234'
var group_index = 0

var username = "Player"

func _ready():
	inputField.connect("text_entered", self, "text_entered")
	change_group(0)

func _input(event):
	if event is InputEventKey:
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

func add_message(username, text, group = 0, remote_msg = false):
	if len(text) > 0:
		chatLog.bbcode_text += '[color=' + groups[group]['color'] +']'
		chatLog.bbcode_text += '[' + username + ']: '
		chatLog.bbcode_text += text
		chatLog.bbcode_text += '[/color]'
		chatLog.bbcode_text += '\n'
		
		if not remote_msg:
			rpc_unreliable("n_add_message", username, text, group)

remote func n_add_message(username, text, group):
	add_message(username, text, group, true)

func add_system_message(text):
	if len(text) > 0:
		chatLog.bbcode_text += '[color=' + system_color +']'
		chatLog.bbcode_text += text
		chatLog.bbcode_text += '[/color]'
		chatLog.bbcode_text += '\n'

func text_entered(text):
	add_message(username, text, group_index)
	inputField.text = ''
	if len(text) > 0:
		inputField.release_focus()
