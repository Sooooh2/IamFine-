extends Node2D

@onready var player: CharacterBody2D = $playerW
@onready var dialogue: CanvasLayer = $dialogue
@onready var server_w: Node2D = $serverW

@onready var clienta1: Node2D = $clientA
@onready var clienta2: Node2D = $clientw2


var pigeon_scene = preload("res://systems/websockets/pigeon/pigeon_w.tscn")

var connections = {}
var clients = []
var update_count := 0
var pending_pigeons = []
var outgoing_pigeons = []


func _ready():
	clients = [clienta1, clienta2]
	for client in clients:
		connections[client] = false
		client.interacted.connect(_on_client_interacted.bind(client))
		client.player_entered.connect(_on_client_entered.bind(client))
		client.dialogue_requested.connect(_show_dialogue)
		client.update_received.connect(_on_update_received.bind(client))

	server_w.player_entered.connect(_on_server_entered)


func _on_client_interacted(clicked_client):

	print("MAIN: client interacted -> ",clicked_client.name)
	print("MAIN: connection state -> ",connections[clicked_client])

	if not connections[clicked_client]:
		start_connection(clicked_client)
	else:
		_show_dialogue("The connection with " + clicked_client.name + " is already open.")


func _on_client_entered(clicked_client):
	for pigeon in pending_pigeons:
		if pigeon.target_client == clicked_client:
			print("Correct pigeon delivered to ",clicked_client.name)
			if pigeon.deliver_to_client(clicked_client):
				pending_pigeons.erase(pigeon)
			return


func start_connection(target_client):
	print("MAIN: STARTING CONNECTION -> ",target_client.name)
	connections[target_client] = true
	target_client.connected = true
	print("MAIN: connection is now -> ",connections[target_client])

	_show_dialogue("Connection established with " + target_client.name)

	schedule_update(target_client)


func schedule_update(target_client):

	print("MAIN: schedule_update called for ",target_client.name," connection = ",connections[target_client])

	if not connections[target_client]:
		print("MAIN: connection is FALSE, stopping")

		return

	var delay = randf_range(2.5, 4.0)

	await get_tree().create_timer(delay).timeout

	print("MAIN: timer finished for ",target_client.name," connection = ",connections[target_client])

	if not connections[target_client]:
		print("MAIN: connection died while waiting")
		return

	if randf() < 0.3:
		send_update(target_client)

	else:
		schedule_update(target_client)

func send_update(target_client):
	update_count += 1
	print("Server: sending update ",update_count," to ",target_client.name)

	var pigeon = pigeon_scene.instantiate()

	add_child(pigeon)

	pigeon.global_position = server_w.global_position

	pigeon.setup(player,"Update #%d has arrived!" % update_count)

	pigeon.target_client = target_client
	pigeon.set_target_client(target_client)

	pigeon.is_to_server = false

	pending_pigeons.append(pigeon)

	schedule_update(target_client)


func _on_update_received(receiving_client):

	print("Update received by: ", receiving_client.name)

	var response_chance = randf()

	print("Client response roll: ", response_chance)

	if response_chance < 0.9:
		send_client_update(receiving_client)

	if update_count >= 2 and randf() < 0.3:
		connection_lost(receiving_client)


func connection_lost(target_client):
	connections[target_client] = false
	target_client.connection_lost()
	print("Connection lost with ",target_client.name)
	_show_dialogue("Connection with " + target_client.name + " was lost.")


func send_client_update(from_client):
	print(from_client.name," is sending an update to the server")
	var pigeon = pigeon_scene.instantiate()
	add_child(pigeon)
	pigeon.global_position = from_client.global_position
	pigeon.setup(player,"%s sent a message to the server!" % from_client.name)
	pigeon.target_client = null
	pigeon.source_client = from_client
	pigeon.is_to_server = true
	outgoing_pigeons.append(pigeon)


func _on_server_entered():
	for pigeon in outgoing_pigeons:
		if pigeon.is_to_server:
			print("Client message delivered to server from ",pigeon.source_client.name)

			pigeon.deliver_to_server()
			outgoing_pigeons.erase(pigeon)

			return

func _show_dialogue(text):
	dialogue.show_msg(text)
