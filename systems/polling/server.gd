extends Node2D

signal interacted
signal dialogue_requested(text)
signal update_found

@export var requests_needed := 3
@onready var label: Label = $Label
@onready var anim: AnimationPlayer = $anim

var has_update := false


var update_dialogue = [
	"There is an update! Here you go.",
	"There you are, here is the update!"
]

var no_update_dialogue = [
	"There is no update yet buddy.",
	"No uppdates!",
	"Nothing new!"
]


func _ready():
	anim.play("idle")
	$interactionArea.body_entered.connect(_on_interaction_area_body_entered)
	$interactionArea.body_exited.connect(_on_interaction_area_body_exited)



func interact():

	interacted.emit()

	has_update = randf() < 0.7

	if has_update:
		dialogue_requested.emit(update_dialogue.pick_random())
		update_found.emit()
	else:
		dialogue_requested.emit(no_update_dialogue.pick_random())


func _on_interaction_area_body_entered(body) -> void:
	if body.is_in_group("player"):
		label.visible = true
		body.nearby_interactable = self



func _on_interaction_area_body_exited(body) -> void:
	if body.is_in_group("player"):
		label.visible = false
		if body.nearby_interactable == self:
			body.nearby_interactable = null
