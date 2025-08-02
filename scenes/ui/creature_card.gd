@tool
class_name CreatureCard extends PanelContainer

@export var species: SpeciesResource:
	set(value):
		species = value
		_set_species(value)

func _set_species(sp: SpeciesResource) -> void:
	if sp == null:
		%CreatureSprite.texture = null
		%CreatureTitle.text = ""
		%Size.text = ""
		%Family.text = ""
		%Effect.text = "Hover over a creature to view its information."
		%RangeValue.text = ""
		%CreatureTitle.hide()
		%MiddleLine.hide()
		%RangeIcon.hide()
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
