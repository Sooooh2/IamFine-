extends CanvasLayer

@onready var label: Label = $Panel/Label
@onready var timer: Timer = $Timer
@export var text_speed := 0.04

func _ready() -> void:
	label.visible = false

func show_msg(message: String) -> void:
	label.visible = true
	label.text = ""
	for character in message:
		label.text += character
		await get_tree().create_timer(text_speed).timeout
	await timer.timeout
	label.visible = false


func _on_timer_timeout() -> void:
	label.visible = false
