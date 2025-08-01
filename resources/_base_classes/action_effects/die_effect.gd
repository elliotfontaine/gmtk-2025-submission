class_name DieEffect extends ActionEffect

func _apply(creature, world) -> void:
	world.suicide(creature)
