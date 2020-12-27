extends Control

onready var nameText = find_node("NameText")
onready var hostButton = find_node("Host")
onready var joinButton = find_node("Join")
onready var serverAddress = find_node("ServerAddress")
onready var errorText = find_node("Error")

func _ready():
	errorText.visible = false

func _on_Host_pressed():
	var name = nameText.text.strip_edges()
	var check = check_name(name)

	if check:
		start_server(name, "default")

func _on_Join_pressed():
	var name = nameText.text.strip_edges()
	var address = serverAddress.text.strip_edges()
	var check = check_name(name) and check_address(address)
	
	if check:
		join_server(name, address, "default")

func start_server(name, port):
	Net.start_server(name, port)

func join_server(name, ip, port):
	Net.join_server(name, ip, port)

func check_name(name):
	if name.length() == 0:
		errorText.text = "Please enter a name"
		errorText.visible = true
		return false
	errorText.visible = false
	return true
	
func check_address(address):
	if address.length() == 0:
		errorText.text = "Please enter a server address"
		errorText.visible = true
		return false
	errorText.visible = false
	return true
