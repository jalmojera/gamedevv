class_name food
extends Area2D


func _process(delta):
	if get_overlapping_areas().pop_front() is Segment:
		SignalBus.respawn_food_requested.emit()
		queue_free()


func _on_area_entered(area):
	if area is Head:
		await area.tw.finished
		SignalBus.food_eaten.emit()
		queue_free()
