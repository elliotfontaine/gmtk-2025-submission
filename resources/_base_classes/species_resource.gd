class_name SpeciesResource
extends Resource

@export var id: Constants.SPECIES
@export var family: Constants.FAMILIES
@export var size: Constants.SIZES
@export var rarity: Constants.RARITIES

@export var title: String
@export var texture: CompressedTexture2D
##creatures that have no effects that use range have a range of 0:
@export_range(0, 5) var default_range: int
@export var effect_text: String = "No effect text."
@export var value: int

@export var sfx_placed :AudioStream
#@export var sfx_trigger :AudioStream
#@export var sfx_death :AudioStream
