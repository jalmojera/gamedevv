class_name Food
extends Area2D


func _on_area_entered(area):
	if area is Head:
		get_tree().current_scene._on_food_eaten()
		queue_free()

	elif area is Segment:
		get_tree().current_scene.create_food()
		queue_free()
