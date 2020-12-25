extends Control

func _ready():
    pass

func _process(_delta):
    pass

func start_server(name, port):
    net.start_server(name, port)

func join_server(name, ip, port):
    net.join_server(name, ip, port)