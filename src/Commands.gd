extends Node

var commands = {
	"help": funcref(self, "get_help"),
	"players": funcref(self, "get_players"),
	"ids": funcref(self, "get_ids")
}

var aliases = {
	"commands": "help",
	"list": "players",
	"listid": "ids"
}

var descriptions = {
	"help": "Get a list of all available commands",
	"players": "Get a list of all players",
	"ids": "Get a list of all player IDs"
}

func process_command(command):
	if not command in commands.keys():
		if not command in aliases.keys():
			return "Command not recognised. Type /help for a list of commands"
		return commands[aliases[command]].call_func()
	return commands[command].call_func()

func get_help():
	var header = "List of commands:"
	var body = ""
	for k in descriptions:
		body += ("\n - /%s: %s" % [k, descriptions[k]])
	return [header, body]

func get_players():
	print("called")
	var header = "Players:\n"
	var body = Net.players.values()
	if len(body) == 0:
		body = " - []"
	else:
		body = " - " + str(body)
	return [header, body]

func get_ids():
	print("called2")
	var header = "Player IDs:\n"
	var body = Net.players.keys()
	if len(body) == 0:
		body = " - []"
	else:
		body = " - " + str(body)
	return [header, body]
