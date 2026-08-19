extends Node2D

signal interacted
signal dialogue_requested(text)
signal update_found

@export var requests_needed := 3
@onready var label: Label = $Label

var has_update := false


func _ready():
	$interactionArea.body_entered.connect(_on_interaction_area_body_entered)
	$interactionArea.body_exited.connect(_on_interaction_area_body_exited)




func interact():

	interacted.emit()

	has_update = randf() < 0.3

	if has_update:
		dialogue_requested.emit("There is an update!")
		update_found.emit()
	else:
		dialogue_requested.emit("There is no update.")


func _on_interaction_area_body_entered(body) -> void:
	if body.is_in_group("player"):
		label.visible = true

		body.nearby_interactable = self



func _on_interaction_area_body_exited(body) -> void:
	if body.is_in_group("player"):
		label.visible = false

		if body.nearby_interactable == self:
			body.nearby_interactable = null
