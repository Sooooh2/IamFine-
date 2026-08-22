extends Node2D

signal interacted
signal dialogue_requested(text)

var first_interaction := true
@onready var label: Label = $Label
@onready var anim: AnimationPlayer = $anim


func _ready():
	label.visible = false
	anim.play("womanIdle")
	$interactionArea.body_entered.connect(_on_interaction_area_body_entered)
	$interactionArea.body_exited.connect(_on_interaction_area_body_exited)

func interact():

	interacted.emit()

	if first_interaction:
		first_interaction = false
		dialogue_requested.emit("Go check the server.")
		print("check for update")
	else:
		dialogue_requested.emit("Nothing yet? Go check again.")
		


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		label.visible = true

		body.nearby_interactable = self


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		label.visible = false

		if body.nearby_interactable == self:
			body.nearby_interactable = null
