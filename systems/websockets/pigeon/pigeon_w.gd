extends Node2D

@export var speed := 250.0
@export var follow_distance := 50.0

@onready var label: Label = $Label

var target: Node2D

var target_client: Node2D
var source_client: Node2D

var is_to_server := false

var message := ""


func setup(target_node: Node2D, new_message: String):

	target = target_node
	message = new_message


func set_target_client(client: Node2D):

	target_client = client
	label.text = client.name


func _process(delta):

	if not target:
		return

	var distance = global_position.distance_to(
		target.global_position
	)

	if distance > follow_distance:

		global_position = global_position.move_toward(
			target.global_position,
			speed * delta
		)


func deliver_to_client(client):

	if client != target_client:

		print("Wrong client!")

		return false

	print(
		"Correct client!"
	)

	client.receive_update(message)

	queue_free()

	return true


func deliver_to_server():

	if not is_to_server:
		return

	print("SERVER RECEIVED: ",message)

	queue_free()
