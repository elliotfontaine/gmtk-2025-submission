extends Resource
class_name SpeciesData

@export var id :String
@export var title :String

enum TYPES {plant, animal, insect, mushroom}
@export var type :TYPES

enum SIZES {small, medium, large}
@export var size :SIZES

@export var texture :CompressedTexture2D

enum RARITIES {common, uncommon, rare}
@export var rarity :RARITIES

@export var range :int
@export var value :int

#@export var sfx_trigger :AudioStream
#@export var sfx_death :AudioStream
