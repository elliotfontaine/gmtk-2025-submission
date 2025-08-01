class_name ReproduceEffect extends ActionEffect

@export var child_number: int = 1

func _apply(creature: Creature, world: World) -> void:
	world.add_creature(child_number, creature.species.id, world.creatures.find(creature))
