extends Control


# to increase speed of pattern as level goes on or anxiety and confidence go up and down 
@onready var grid: HBoxContainer = $grid


var sequence = []
var player_seq = []

var grid_size := 5
var seq_len := 5

# in future to update patience, anxiousness,confidence accordingly 
var strike := 0

var can_click := false

func _ready() -> void:
	randomize()
	gen_sequence()
	setup_cell()
	show_pattern()


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
	can_click = false

	for pos in sequence:
		var cell = get_cell(pos.x, pos.y)
		cell.modulate = Color.PALE_VIOLET_RED
		await get_tree().create_timer(0.4).timeout
		cell.modulate = Color.WHITE
		await get_tree().create_timer(0.2).timeout
	
	can_click = true


# create grid for player to click
func setup_cell():
	for x in range(grid_size):
		for y in range(grid_size):
			var cell = get_cell(x,y)
			if not cell.gui_input.is_connected(_on_cell_clicked):
				cell.gui_input.connect(_on_cell_clicked.bind(x, y))


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
func check_answer(pos: Vector2i):
	if player_seq.size() >= sequence.size():
		return
	var curr_index = player_seq.size()
	if pos == sequence[curr_index]:
		player_seq.append(pos)
		print("correct")
		
		if player_seq.size() == sequence.size():
			print("you win")
	else: 
		strike += 1
		print("Incorrect!")
	
	if strike >= 3: 
		print("you loooseeee")
