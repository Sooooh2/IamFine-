extends MeshInstance2D

@export var width: float = 50.0


func _ready() -> void:
	generate_track()


func generate_track() -> void:
	var path: Path2D = get_parent() as Path2D

	if path == null:
		push_error("Track must be a child of a Path2D.")
		return

	if path.curve == null:
		push_error("Path2D has no Curve2D.")
		return

	var points: PackedVector2Array = path.curve.get_baked_points()

	if points.size() < 2:
		return

	var vertices := PackedVector2Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	for i: int in range(points.size()):
		var direction: Vector2

		if i == 0:
			direction = points[1] - points[0]
		elif i == points.size() - 1:
			direction = points[i] - points[i - 1]
		else:
			direction = points[i + 1] - points[i - 1]

		direction = direction.normalized()

		var normal := Vector2(
			-direction.y,
			direction.x
		)

		var left := points[i] + normal * width * 0.5
		var right := points[i] - normal * width * 0.5

		vertices.append(left)
		vertices.append(right)

		var u: float = float(i) / float(points.size() - 1)

		uvs.append(Vector2(u, 0.0))
		uvs.append(Vector2(u, 1.0))

	for i: int in range(points.size() - 1):
		var index: int = i * 2

		indices.append(index)
		indices.append(index + 2)
		indices.append(index + 1)

		indices.append(index + 1)
		indices.append(index + 2)
		indices.append(index + 3)

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES,
		arrays
	)

	mesh = array_mesh
