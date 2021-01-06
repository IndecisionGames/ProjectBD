extends Node

const DEFAULT_PORT = 31416
const DEFAULT_IP   = '127.0.0.1'
const MAX_PEERS    = 16
var   players      = {}
var   player_name
var	  status       = 0	# 0 - nothing, 1 - connecting.., -1 - failed to join server

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func start_server(name, port):
	status = 1
	player_name = name
	Chat.set_username(name)
	var host = NetworkedMultiplayerENet.new()

	if port == "default":
		port = DEFAULT_PORT
	
	var err = host.create_server(port, MAX_PEERS)
	
	if (err!=OK):
		return
	
	status = 0
	get_tree().set_network_peer(host)
	load_lobby_scene()
	Chat.add_system_message("Server created on port " + str(port))

	spawn_player(1)
	
func join_server(name, ip, port):
	status = 1
	player_name = name
	Chat.set_username(name)
	var host = NetworkedMultiplayerENet.new()

	if ip == "default" or ip == "0" or ip == "localhost":
		ip = DEFAULT_IP
	
	if port == "default":
		port = DEFAULT_PORT

	host.create_client(ip, port)

	get_tree().set_network_peer(host)
	
func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", get_tree().get_network_unique_id(), player_name)

func _player_disconnected(id):
	unregister_player(id)
	rpc("unregister_player", id)
	players.erase(id) # Erase player from info.
	remove_from_lobby(id)

func _connected_ok():
	status = 0
	load_lobby_scene()
	var server_owner = str(get_node("/root/Lobby").get_network_master())
	Chat.add_system_message("Joined " + server_owner + "'s server.") # Only called on clients, not server.
	rpc_id(1, "user_ready", get_tree().get_network_unique_id(), player_name)

func _connected_fail():
	# Could not connect to server.
	status = -1	
		
remote func user_ready(id, _name):
	if get_tree().is_network_server():
		rpc_id(id, "register_in_game")
		
remote func register_in_game():
	rpc("register_new_player", get_tree().get_network_unique_id(), player_name)
	register_new_player(get_tree().get_network_unique_id(), player_name)

func _server_disconnected():
	Chat.add_system_message("Server disconnected.")
	quit_game()

remote func register_new_player(id, name):
	if get_tree().is_network_server():
		rpc_id(id, "register_new_player", 1, player_name)
		
		for peer_id in players:
			rpc_id(id, "register_new_player", peer_id, players[peer_id])
		
	players[id] = name
	spawn_player(id)
	
remote func register_player(id, name):			
	players[id] = name

	# Call function to update lobby UI here
	add_to_lobby(id)
	
remote func unregister_player(id):
	get_node("/root/" + str(id)).queue_free()
	players.erase(id)

func add_to_lobby(id):
	Chat.add_system_message("Player " + str(id) + " joined.")
	
func remove_from_lobby(id):
	Chat.add_system_message("Player " + str(id) + " left.")

func quit_game():
	get_tree().set_network_peer(null)
	players.clear()
		
func spawn_player(id):
	var player = preload("res://src/player/Player.tscn").instance()
		
	player.set_name(str(id))
	player.set_position(Vector2(500, 300))
	player.player_id = id
		
	if id == get_tree().get_network_unique_id():
		player.set_network_master(id)
		player.control   = true
	else:
		player.process_ghost_player()
			
	#get_node("/root/World/Entities/Characters").call_deferred('add_child', player)
	print('Spawned Player at:', player.get_position())

func load_lobby_scene():
	SceneManager.goto_scene("res://src/Lobby.tscn")
