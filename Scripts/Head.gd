class_name Head
extends Area2D


var input_dir: Dictionary = {
	"move_up": Vector2.UP,
	"move_down": Vector2.DOWN,
	"move_left": Vector2.LEFT,
	"move_right": Vector2.RIGHT
}


var tw: Tween
var can_move: bool = true
var current_dir: Vector2 = input_dir["move_right"]
@onready var turn = $move
@onready var anim = $AnimatedSprite2D  

var grid_size: int = 32
var speed: float = 8.0
var rot_speed: float


func _unhandled_input(event):
	for key in input_dir:
		if event.is_action_pressed(key):
			current_dir = input_dir[key]
			$move.play()
			update_animation()   # <-- added


func update_animation():
	if current_dir == Vector2.UP:
		anim.play("up")
		anim.flip_h = false

	elif current_dir == Vector2.DOWN:
		anim.play("down")
		anim.flip_h = false

	elif current_dir == Vector2.RIGHT:
		anim.play("sides")
		anim.flip_h = false

	elif current_dir == Vector2.LEFT:
		anim.play("sides")   
		anim.flip_h = true  


func _process(delta):
	rot_speed = speed
	
	if can_move:
		SignalBus.has_moved.emit(speed)
		can_move = false

		tw = create_tween()
		tw.tween_property(self, "position", position + current_dir * grid_size, 1.0 / speed)

	await tw.finished
	can_move = true
