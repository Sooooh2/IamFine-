extends Path2D

@export var particle_count: int = 150
@export var track_width: float = 40.0

func _ready() -> void:
	if curve == null:
		return

	var length: float = curve.get_baked_length()

	for i in particle_count:
		var offset: float = randf_range(0.0, length)

		var pos: Vector2 = curve.sample_baked(offset)
		var next_pos: Vector2 = curve.sample_baked(
			min(offset + 1.0, length)
		)

		var tangent: Vector2 = (next_pos - pos).normalized()
		var normal: Vector2 = Vector2(-tangent.y, tangent.x)

		var width_offset: float = randf_range(
			-track_width * 0.5,
			track_width * 0.5
		)

		var particle: Sprite2D = Sprite2D.new()
		particle.texture = create_particle_texture()
		particle.position = pos + normal * width_offset
		particle.scale = Vector2.ONE * randf_range(0.4, 1.0)
		particle.modulate.a = randf_range(0.2, 0.8)

		add_child(particle)


func create_particle_texture() -> ImageTexture:
	var image: Image = Image.create(
		16,
		16,
		false,
		Image.FORMAT_RGBA8
	)

	for x: int in 16:
		for y: int in 16:
			var dist: float = Vector2(x, y).distance_to(
				Vector2(7.5, 7.5)
			)

			var alpha: float = clamp(
				1.0 - dist / 8.0,
				0.0,
				1.0
			)

			image.set_pixel(
				x,
				y,
				Color(1.0, 1.0, 1.0, alpha)
			)

	return ImageTexture.create_from_image(image)
