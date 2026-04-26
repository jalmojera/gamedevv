class_name Segment
extends Area2D

@onready var anim = $AnimatedSprite2D

var is_active: bool = false
var last_position: Vector2


func _ready():
	SignalBus.has_moved.connect(_on_player_moved)
	last_position = position


func _on_player_moved(speed: float):
	if not is_active:
		var tw = create_tween()
		tw.set_ease(Tween.EASE_OUT)
		tw.set_trans(Tween.TRANS_QUART)

		tw.tween_property(self, "scale", Vector2(1, 1), 1.0 / speed).from(Vector2(0, 0))
		await tw.finished
		is_active = true

	var dir = position - last_position
	last_position = position

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
		SignalBus.game_lost.emit()
