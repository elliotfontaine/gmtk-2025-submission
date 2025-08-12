class_name SpeciesResource
extends Resource

@export var id: Constants.SPECIES
@export var family: Constants.FAMILIES
@export var size: Constants.SIZES
@export var rarity: Constants.RARITIES = Constants.RARITIES.COMMON

@export var title: String
##creatures that have no effects that use range have a range of 0:
@export_range(0, 5) var default_range: int
@export_multiline var effect_text: String = "No effect text."
@export var score_reward_1: int = 0
@export var score_reward_2: int = 0
@export var money_reward_1: int = 0
@export var money_reward_2: int = 0
@export var base_price: int = 1

@export_category("Visuals")
@export var texture: CompressedTexture2D
@export var shadow_x_scale: float = 1.0
@export var shadow_y_scale: float = 1.0
@export var shadow_x_offset: float = 0.0
@export var shadow_y_offset: float = 0.0

@export_category("Audio")
@export var sfx_placed :AudioStream
@export var sfx_eat :AudioStream
#@export var sfx_death :AudioStream
