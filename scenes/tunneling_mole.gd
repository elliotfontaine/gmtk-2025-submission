extends AnimatedSprite2D

func _on_animation_finished() -> void:
	await get_tree().create_timer(randf_range(0.1,3.0)).timeout
	
	var y :float = randf_range(50,1080-100)
	var x :float
	if randi()%2:
		x = randf_range(100,500)
	else:
		x = randf_range(1400,1920-100)
	position = Vector2(x,y)
	
	play("default")
