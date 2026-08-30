extends Control


signal minigame_finished(confidence_change: float, anxiety_change: float)

# to increase speed of pattern as level goes on or anxiety and confidence go up and down 
@onready var grid: HBoxContainer = $grid
@onready var cam: Camera2D = $cam


var sequence = []
var player_seq = []

var difficulties = {
	"easy": {
		"seq_len": 4,
		"show_time": 0.5,
		"gap_time": 0.25,
		"shake_amount": 0.1,
		"input_time": 10.0,
		"grid_size": 5,
	},

	"medium": {
		"seq_len": 5,
		"show_time": 0.4,
		"gap_time": 0.2,
		"shake_amount": 0.3,
		"input_time": 7.0,
		"grid_size": 5,
	},

	"hard": {
		"seq_len": 7,
		"show_time": 0.25,
		"gap_time": 0.1,
		"shake_amount": 0.6,
		"input_time": 5.0,
		"grid_size": 5,
	}
}

var grid_size := 5
var seq_len
var shake_amount 
var gap_time 
var show_time 
var curr_diff := "hard"
# in future to update patience, anxiousness,confidence accordingly 
var strike := 0

var can_click := false

func _ready() -> void:
	Global.register_cam(cam)
	randomize()
	setup_difficulty()

	gen_sequence()
	setup_cell()
	show_pattern()


func setup_difficulty() -> void:
	var settings = difficulties[curr_diff]
	seq_len = settings["seq_len"]
	shake_amount = settings["shake_amount"]
	gap_time = settings["gap_time"]
	show_time = settings["show_time"]
	grid_size = settings["grid_size"]


# get colorRect grid 
func get_cell(x: int, y: int) -> ColorRect:
	return grid.get_child(x).get_child(y)


# generate sequence 
func gen_sequence():
	sequence.clear()
	for i in range(seq_len):
		var x = randi_range(0,grid_size-1)
		var y = randi_range(0,grid_size-1)
		
		sequence.append(Vector2i(x,y))


# show the pattern 
func show_pattern():
	await get_tree().create_timer(3.0).timeout
	can_click = false
	for pos in sequence:
		var cell = get_cell(pos.x, pos.y)
		cell.modulate = Color.PALE_VIOLET_RED
		await get_tree().create_timer(show_time).timeout
		cell.modulate = Color.WHITE
		await get_tree().create_timer(gap_time).timeout
	can_click = true


# create grid for player to click
func setup_cell():
	for x in range(grid_size):
		for y in range(grid_size):
			var cell = get_cell(x,y)
			var callable = _on_cell_clicked.bind(x, y)

			if not cell.gui_input.is_connected(callable):
				cell.gui_input.connect(callable)


# handle player input
func _on_cell_clicked(event: InputEvent, x: int, y: int):
	if not can_click:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var cell = get_cell(x,y)
			cell.modulate = Color.KHAKI
			check_answer(Vector2i(x, y))
			await get_tree().create_timer(0.4).timeout
			cell.modulate = Color.WHITE


# check player's pattern
func check_answer(pos: Vector2i) -> void:
	if player_seq.size() >= sequence.size():
		return

	var curr_index = player_seq.size()

	if pos == sequence[curr_index]:
		player_seq.append(pos)
		print("correct")

		if player_seq.size() == sequence.size():
			print("you win")
			minigame_finished.emit(10.0, -8.0)
			queue_free()
	else:
		wrong_click()

func wrong_click() -> void:
	strike += 1
	player_seq.clear()

	print("Incorrect!")

	if strike > 1:
		minigame_finished.emit(-10.0, 10.0)

	if strike >= 4:
		game_lost()
		return

	print("start again")
	Global.shake(0.2)
	show_pattern()


func game_lost() -> void:
	can_click = false
	minigame_finished.emit(-15.0, 20.0)

	await get_tree().create_timer(3.0).timeout
	queue_free()
