extends Sprite2D

var species: SpeciesData:
	set(new_species):
		texture = new_species.texture
		species = new_species

func _ready() -> void:
	if species == null:
		texture = null

func _process(delta: float) -> void:
	position = get_global_mouse_position()
