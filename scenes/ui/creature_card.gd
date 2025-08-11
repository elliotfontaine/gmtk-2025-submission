@tool
class_name CreatureCard extends PanelContainer

const no_bg = preload("res://assets/sprites/ui/creature_background.png")
const common_bg = preload("res://assets/sprites/ui/rarity_common.png")
const uncommon_bg = preload("res://assets/sprites/ui/rarity_uncommon.png")
const rare_bg = preload("res://assets/sprites/ui/rarity_rare.png")

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
		%CreatureBackground.texture = no_bg
		
	else:
		%CreatureSprite.texture = sp.texture
		
		match sp.rarity:
			Constants.RARITIES.COMMON:
				%CreatureBackground.texture = common_bg
			Constants.RARITIES.UNCOMMON:
				%CreatureBackground.texture = uncommon_bg
			Constants.RARITIES.RARE:
				%CreatureBackground.texture = rare_bg
			_:
				%CreatureBackground.texture = no_bg
		%CreatureTitle.text = sp.title
		%Size.text = Constants.size_strings[sp.size]
		%Family.text = Constants.family_strings[sp.family]
		%Effect.text = convert_text(sp.effect_text)
		if sp.default_range != 0:
			%RangeValue.text = str(sp.default_range)
			%RangeIcon.show()
		else:
			%RangeValue.text = "none"
			%RangeIcon.hide()
		%CreatureTitle.show()
		%MiddleLine.show()


##takes in description text and converts keywords into icons
func convert_text(text:String) -> String:
	if text == "":
		return text
	
	var enhanced_text :String = ""
	
	for word in text.split(" ",false):
		var stored_puncuation :String
		if word[-1] in [".", ",", "!", "?", ":", ";"]:
			stored_puncuation = word[-1]
			word = word.left(word.length() - 1)
		
		if word == "trophies":
			enhanced_text += "[img={20, 20}]res://assets/sprites/ui/small_trophy.png[/img]"
		else:
			enhanced_text += word
		
		if stored_puncuation:
			enhanced_text += stored_puncuation
		enhanced_text += " "
	
	
	return enhanced_text
