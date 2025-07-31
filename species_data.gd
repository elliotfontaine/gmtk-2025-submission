extends Resource
class_name SpeciesData

@export var id :String
@export var title :String

@export var type :Array[TYPES]

@export var texture :CompressedTexture2D

enum TYPES {small, medium, large, plant, animal, insect}
