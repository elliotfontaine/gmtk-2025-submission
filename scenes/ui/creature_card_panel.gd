@tool
extends PanelContainer

@export var current_species: SpeciesResource:
	set(value):
		current_species = value
		_set_species(value)

func _set_species(sp: SpeciesResource) -> void:
	if sp == null:
		%CreatureSprite.texture = null
		%CreatureTitle.hide()
		%MiddleLine.hide()
		%Effect.text = "click on a creature to show its info."
	else:
		%CreatureSprite.texture = sp.texture
		%CreatureTitle.text = sp.title
		%Size.text = Constants.size_strings[sp.size]
		%Family.text = Constants.family_strings[sp.family]
		%Effect.text = sp.effect_text
		if sp.default_range != 0:
			%RangeValue.text = str(sp.default_range)
			%RangeIcon.show()
		else:
			%RangeValue.text = "none"
			%RangeIcon.hide()
		%CreatureTitle.show()
		%MiddleLine.show()
