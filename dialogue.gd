extends CanvasLayer

@onready var label: Label = $Label
@onready var timer: Timer = $Timer

func _ready():
	label.visible = false


func show_msg(message: String):

	label.text = message
	label.visible = true
	timer.start()


func _on_timer_timeout():

	label.visible = false
