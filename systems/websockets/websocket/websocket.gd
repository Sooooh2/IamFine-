extends Node2D

@onready var player: CharacterBody2D = $playerW
@onready var dialogue: CanvasLayer = $dialogue
@onready var server_w: Node2D = $serverW
@onready var client: Node2D = $clientA
@onready var clienta2: Node2D = $clientA2
@onready var clienta3: Node2D = $clientA3

var pigeon_scene = preload("res://systems/websockets/pigeon/pigeon_w.tscn")

var connection_alive := false
var update_count := 0


func _ready():
	var pig_sp = server_w.global_position
	client.interacted.connect(_on_client_interacted)
	client.dialogue_requested.connect(_show_dialogue)
	client.update_received.connect(_on_update_received)


func _on_client_interacted():

	if not connection_alive:
		start_connection()
	else:
		_show_dialogue("The connection is already open.")


func start_connection():

	connection_alive = true
	print("dfsdckj")
	_show_dialogue("Connection established. Wait for updates.")

	schedule_update()


func schedule_update():

	if not connection_alive:
		return
	print("schedule made for client ")
	var delay = randf_range(0.5, 1.0)

	await get_tree().create_timer(delay).timeout

	if not connection_alive:
		return

	if randf() < 0.7:
		send_update()
	else:
		schedule_update()


func send_update():

	update_count += 1

	print("Server: sending update ", update_count)

	var pigeon = pigeon_scene.instantiate()

	add_child(pigeon)

	pigeon.global_position = server_w.global_position

	pigeon.setup(
		player,
		"Update #%d has arrived!" % update_count
	)

	schedule_update()


func _on_update_received():

	print("Client received update")

	if update_count >= 2 and randf() < 0.3:
		connection_lost()


func connection_lost():

	connection_alive = false
	client.connection_lost()

	_show_dialogue("Connection lost.")
	await get_tree().create_timer(2.0).timeout

	queue_free()


func _show_dialogue(text):
	dialogue.show_msg(text)
