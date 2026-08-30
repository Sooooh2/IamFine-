extends CanvasLayer

@onready var dialogue: Label = $dialogueBox/dialogue
@onready var msg: RichTextLabel = $msgBox/msg
@onready var timer: Timer = $Timer
@export var text_speed := 0.04

func _ready() -> void:
	dialogue.visible = false

func show_msg(message: String) -> void:
	dialogue.visible = true
	dialogue.text = ""
	for character in message:
		dialogue.text += character
		await get_tree().create_timer(text_speed).timeout
	await timer.timeout
	dialogue.visible = false


func _on_timer_timeout() -> void:
	dialogue.visible = false
