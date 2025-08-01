class_name Action extends Resource

@export_group("Reward")
@export var type: Constants.ACTION_REWARD_TYPES
@export var value: int = 0

@export_group("Callbacks")
@export var conditions: Array[ActionCondition]
@export var effects: Array[ActionEffect]

func execute(creature: Creature, world: World) -> void:
	for condition in conditions:
		if not condition._is_satisfied(creature, world):
			return
	for effect in effects:
		effect._apply(creature, world)
	if type == Constants.ACTION_REWARD_TYPES.SCORE:
		world.score_current += value
	
