extends Sprite2D

var species: SpeciesResource:
	set(new_species):
		texture = new_species.texture if new_species != null else null
		species = new_species

func _ready() -> void:
	if species == null:
		texture = null

func _process(_delta: float) -> void:
	position = get_global_mouse_position()
