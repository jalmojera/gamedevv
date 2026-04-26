class_name Segment
extends Area2D

@onready var anim = $AnimatedSprite2D

var is_active: bool = false
var last_position: Vector2


func _ready():
	last_position = position


func _process(delta):
	# spawn animation (runs once)
	if not is_active:
		var tw = create_tween()
		tw.set_ease(Tween.EASE_OUT)
		tw.set_trans(Tween.TRANS_QUART)

		tw.tween_property(self, "scale", Vector2(1, 1), 0.15).from(Vector2(0, 0))
		await tw.finished
		is_active = true

	# detect movement direction
	var dir = position - last_position
	last_position = position

	# ignore if not moving
	if dir == Vector2.ZERO:
		return

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			anim.play("sides")
			anim.flip_h = false
		else:
			anim.play("sides")
			anim.flip_h = true
	else:
		if dir.y > 0:
			anim.play("down")
		else:
			anim.play("up")


func _on_area_entered(area):
	if area is Head and is_active:
		get_tree().current_scene._on_game_lost()
