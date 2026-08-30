extends Path2D

@export var particle_count: int = 150
@export var particle_speed: float = 30.0
@export var particle_distance: float = 30.0

var particles: Array[Sprite2D] = []
var offsets: Array[float] = []
var directions: Array[float] = []
var distances: Array[float] = []


func _ready() -> void:
	if curve == null:
		return

	var length: float = curve.get_baked_length()

	for i in particle_count:
		var offset: float = randf_range(0.0, length)

		var particle: Sprite2D = Sprite2D.new()
		particle.texture = create_particle_texture()
		particle.scale = Vector2.ONE * randf_range(0.4, 1.0)
		particle.modulate.a = randf_range(0.2, 0.8)

		add_child(particle)

		particles.append(particle)
		offsets.append(offset)
		directions.append([-1.0, 1.0].pick_random())
		distances.append(randf_range(0.0, particle_distance))


func _process(delta: float) -> void:
	if curve == null:
		return

	var length: float = curve.get_baked_length()

	for i in particles.size():
		distances[i] += particle_speed * delta

		if distances[i] > particle_distance:
			distances[i] = 0.0
			offsets[i] = randf_range(0.0, length)
			directions[i] = [-1.0, 1.0].pick_random()

		var pos: Vector2 = curve.sample_baked(offsets[i])

		var next_pos: Vector2 = curve.sample_baked(
			min(offsets[i] + 1.0, length)
		)

		var tangent: Vector2 = (next_pos - pos).normalized()
		var normal: Vector2 = Vector2(-tangent.y, tangent.x)

		particles[i].position = pos + normal * distances[i] * directions[i]


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
