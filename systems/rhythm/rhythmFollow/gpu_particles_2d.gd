extends GPUParticles2D

@export var path: Path2D
@export var particle_count := 100

func _ready() -> void:
	if path == null:
		return

	var curve := path.curve
	var length := curve.get_baked_length()

	for i in particle_count:
		var offset := randf_range(0.0, length)
		var pos := curve.sample_baked(offset)
