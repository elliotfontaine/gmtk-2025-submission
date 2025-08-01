class_name EatEffect extends ActionEffect

@export var diet: Array[Constants.FAMILIES]
@export_range(1, 5, 1, "or_greater") var times: int = 1

func _apply(creature: Creature, world: World) -> void:
	for breakfast in range(times):
		if world.eat(creature, creature.current_range, diet):
			continue
		else:
			# If there's nothing to eat, there's nothing to eat !
			break
