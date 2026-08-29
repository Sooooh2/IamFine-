extends Node2D

signal interacted
signal dialogue_requested(text)

var first_interaction := true

@onready var label: Label = $Label
@onready var anim: AnimationPlayer = $anim


var first_talk = [
	"Go and check the server for any updates!",
	"Go and get the updates"
]

var talk = [
	"Ok, go and check again.",
	"Alright, go to the server and ask again."
]

var update = [
	"Okay, thank you for the update. Go check again.",
	"Alright, I understand. Go and check for updates again."
]

var end = [
	"Okay, thank you for your work. You can go now.",
	"Thank you for the work! We are ending here."
]


func _ready():

	label.visible = false
	anim.play("womanIdle")
	$interactionArea.body_entered.connect(_on_interaction_area_body_entered)
	$interactionArea.body_exited.connect(_on_interaction_area_body_exited)


func interact():

	interacted.emit()
	if first_interaction:
		first_interaction = false
		dialogue_requested.emit(first_talk.pick_random())
	else:
		dialogue_requested.emit(talk.pick_random())


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		label.visible = true
		body.nearby_interactable = self


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		label.visible = false
		if body.nearby_interactable == self:
			body.nearby_interactable = null
