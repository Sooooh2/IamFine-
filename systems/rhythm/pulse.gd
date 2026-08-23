extends ColorRect


var speed := 300.0


func _process(delta: float) -> void:
	position.x -= speed * delta
