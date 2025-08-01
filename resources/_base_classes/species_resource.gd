class_name SpeciesResource extends Resource

@export var id: Constants.SPECIES
@export var family: Constants.FAMILIES
@export var size: Constants.SIZES
@export var rarity: Constants.RARITIES

@export var title: String
@export var texture: CompressedTexture2D
@export var effect_text: String
@export_range(1, 5, 1) var default_range: int = 1
@export var action: Action
@export var base_value: int

#@export var sfx_trigger :AudioStream
#@export var sfx_death :AudioStream

func has_action() -> bool:
	return action != null
