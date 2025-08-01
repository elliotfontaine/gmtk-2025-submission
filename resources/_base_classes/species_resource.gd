class_name SpeciesResource
extends Resource

@export var id: Constants.SPECIES
@export var family: Constants.FAMILIES
@export var size: Constants.SIZES
@export var rarity: Constants.RARITIES

@export var title: String
@export var texture: CompressedTexture2D
@export_range(1, 5) var default_range: int
@export var value: int

#@export var sfx_trigger :AudioStream
#@export var sfx_death :AudioStream
