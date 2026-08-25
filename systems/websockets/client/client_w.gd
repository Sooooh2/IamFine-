extends Node2D

signal interacted
signal dialogue_requested(text)
signal update_received
signal player_entered

@onready var label: Label = $Label
@onready var anim: AnimationPlayer = $anim

var connected := false

var first_talk = [
	"Stay connected. I'll receive the updates automatically.",
	"The connection is open. Just wait for the updates."
]

var update_talk = [
	"Got it! Thanks for the update.",
	"Ah, there's the update!",
	"Received. Thank you!"
]

var end_talk = [
	"Looks like the connection is gone.",
	"No more updates. The connection has closed."
]


func _ready():
	#anim.play("idle")

	$interactionArea.body_entered.connect(_on_interaction_area_body_entered)
	$interactionArea.body_exited.connect(_on_interaction_area_body_exited)


func interact():
	print("CLIENT INTERACT CALLED")

	interacted.emit()
	if not connected:
		connected = true
		print("Svsdvsxva")
		dialogue_requested.emit(first_talk.pick_random())
	else:
		dialogue_requested.emit("The connection is already open. Just wait for an update.")


func receive_update(message):
	dialogue_requested.emit(message)
	update_received.emit()


func connection_lost():

	connected = false
	dialogue_requested.emit(end_talk.pick_random())


func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		label.visible = true
		body.nearby_interactable = self
		player_entered.emit()


func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		label.visible = false
		if body.nearby_interactable == self:
			body.nearby_interactable = null
