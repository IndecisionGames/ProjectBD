extends Node

const DEFAULT_PORT = 31416
const MAX_PEERS    = 16
var   players      = {}
var   player_name

onready var chat = get_node("/root/Lobby/ChatBox")

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	start_server()
	
func start_server():
	player_name = 'Server'
	var host = NetworkedMultiplayerENet.new()
	
	var err = host.create_server(DEFAULT_PORT, MAX_PEERS)
	
	if (err!=OK):
		join_server()
		return
	
	#chat.add_system_message("Server created")
	get_tree().set_network_peer(host)
	
func join_server():
	player_name = 'Client'
	var host = NetworkedMultiplayerENet.new()
	
	host.create_client('127.0.0.1', DEFAULT_PORT)
	
	get_tree().set_network_peer(host)
	
func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", player_name)

func _player_disconnected(id):
	players.erase(id) # Erase player from info.
	remove_from_lobby(id)

func _connected_ok():
	var server_owner = str(get_node("/root/Lobby").get_network_master())
	chat.add_system_message("Joined " + server_owner + "'s server.") # Only called on clients, not server.

func _server_disconnected():
	chat.add_system_message("Server disconnected.")

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	players[id] = info

	# Call function to update lobby UI here
	add_to_lobby(id)

func add_to_lobby(id):
	chat.add_system_message("Player " + str(id) + " joined.")
	
func remove_from_lobby(id):
	chat.add_system_message("Player " + str(id) + " left.")

