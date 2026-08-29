extends PathFollow2D

@export var speed: float = 300.0

var previous_progress: float


func _ready() -> void:
	previous_progress = progress


func _process(delta: float) -> void:
	previous_progress = progress

	progress -= speed * delta

	if progress <= 0.0:
		queue_free()
