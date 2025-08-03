class_name SpeciesResource
extends Resource

@export var id: Constants.SPECIES
@export var family: Constants.FAMILIES
@export var size: Constants.SIZES
@export var rarity: Constants.RARITIES = Constants.RARITIES.COMMON

@export var title: String
@export var texture: CompressedTexture2D
##creatures that have no effects that use range have a range of 0:
@export_range(0, 5) var default_range: int
@export_multiline var effect_text: String = "No effect text."
@export var score_reward_1: int = 0
@export var score_reward_2: int = 0
@export var money_reward_1: int = 0
@export var money_reward_2: int = 0
@export var base_price: int = 1

@export var sfx_placed :AudioStream
@export var sfx_eat :AudioStream
#@export var sfx_death :AudioStream
