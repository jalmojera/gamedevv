extends Node2D
@onready var cheken: Node2D = $Cheken
@onready var head: Head = $Cheken/Head
@onready var time: Label = $CanvasLayer/UI/Time
@onready var time_timer: Timer = $CanvasLayer/UI/Time/TimeTimer
@onready var score_text: Label = $CanvasLayer/UI/Score/ScoreText
@onready var game_over: Control = $CanvasLayer/GameOver
@onready var game_over_time: Label = $CanvasLayer/GameOver/VBoxContainer/GameOverTime
@onready var game_over_score: Label = $CanvasLayer/GameOver/VBoxContainer/GameOverScore


@export_range(6.0, 18.0, 0.1) var player_speed: float = 12.0
@export_range(0, 10) var initial_segment_count: int = 3
var tw: Tween
var grid_size: int = 32
var score: int = 0
var seconds: int = 0
var minutes: int = 0


func _ready():
	SignalBus.food_eaten.connect(_on_food_eaten)
	SignalBus.has_moved.connect(_on_player_moved)
	SignalBus.respawn_food_requested.connect(create_food)
	SignalBus.game_lost.connect(_on_game_lost)
	
	head.speed = player_speed
	
	create_food()
	for i in initial_segment_count:
		create_segment()


func _unhandled_input(event):
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_food_eaten():
	score += 1
	score_text.text = "x" + str(score)
	
	$kagat.pitch_scale = randf_range(1.0, 1.4)
	$kagat.play()

	create_food()
	create_segment()


func _on_player_moved(speed: float):
	if cheken.get_child_count() > 1:
		tw = create_tween().set_parallel()
		var segment_positions = get_segment_positions()
		
		for segment_index in cheken.get_child_count():
			var selected_segment = cheken.get_child(segment_index)
			if selected_segment is Segment:
				tw.tween_property(selected_segment, "position", segment_positions[segment_index-1], 1.0/speed)


func _on_game_lost():
	head.can_move = false
	game_over.show()
	head.turn.volume_db = -80
	$talo.play()
	
	game_over_time.text = "TIME: " + time.text
	game_over_score.text = "SCORE: " + str(score)
	time_timer.stop()
	
	if tw:
		tw.stop()
		head.tw.stop()


func _process(delta):
	var temp_seconds: String = "%0*d" % [2, seconds]
	var temp_minutes: String = "%0*d" % [2, minutes] 
	time.text = "TIME: " + temp_minutes + ":" + temp_seconds



func create_food():
	var food = preload("res://Scenes/food.tscn").instantiate()
	
	food.position.x = randi_range(64, 704)
	food.position.y = randi_range(128, 704)
	
	food.position.x = snapped(food.position.x, grid_size)
	food.position.y = snapped(food.position.y, grid_size)
	
	add_child(food)



func create_segment():
	var segment = preload("res://Scenes/Segment.tscn").instantiate()
	
	segment.position = get_tail().position
	
	for selected_segment in cheken.get_children():
		selected_segment.z_index += 1
	
	cheken.call_deferred("add_child", segment)


func get_segment_positions():
	var cheken_body: Array = cheken.get_children()
	var segment_positions: Array
	for segment in cheken_body:
		segment_positions.append(segment.position)
	return segment_positions


func get_tail():
	return cheken.get_children().pop_back()


func _on_time_timer_timeout():
	seconds += 1
	if seconds >= 60:
		seconds = 0
		minutes += 1


func _on_border_area_entered(area):
	if area is Head:
		SignalBus.game_lost.emit()
