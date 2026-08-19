extends Node2D

enum State {
	CLIENT_START,
	GOING_TO_SERVER,
	RETURNING_NO_UPDATE,
	GOING_TO_SERVER_AGAIN,
	RETURNING_WITH_UPDATE,
	COMPLETE
}

var state := State.CLIENT_START

@onready var client: Node2D = $client
@onready var server: Node2D = $server
@onready var player: CharacterBody2D = $player
@onready var dialogue: CanvasLayer = $dialogue


func _ready():
	client.interacted.connect(_on_client_interacted)
	server.interacted.connect(_on_server_interacted)

	client.dialogue_requested.connect(_show_dialogue)
	server.dialogue_requested.connect(_show_dialogue)

	server.update_found.connect(_on_update_found)


func _on_client_interacted():

	match state:

		State.CLIENT_START:
			state = State.GOING_TO_SERVER

		State.RETURNING_NO_UPDATE:
			state = State.GOING_TO_SERVER_AGAIN

		State.RETURNING_WITH_UPDATE:
			complete_minigame()


func _on_server_interacted():

	match state:

		State.GOING_TO_SERVER:
			state = State.RETURNING_NO_UPDATE

		State.GOING_TO_SERVER_AGAIN:
			state = State.RETURNING_NO_UPDATE

		_:
			return


func _on_update_found():

	state = State.RETURNING_WITH_UPDATE


func complete_minigame():

	state = State.COMPLETE

	player.can_move = false

	_show_dialogue("Okay, got it!")


func _show_dialogue(text):
	dialogue.show_msg(text)
