class_name TypedNeighborsCondition extends ActionCondition

@export var is_blacklist: bool = false
@export var types: Array[Constants.FAMILIES]

func _is_satisfied(creature: Node, world: Node) -> bool:
	var neighbours_found: bool = world.check_neighbours_types(creature, creature.current_range, types)
	return is_blacklist != neighbours_found
