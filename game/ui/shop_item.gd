extends HBoxContainer

var sprite: Texture:
	get: return %CreatureSprite.texture
	set(value): %CreatureSprite.texture = value

var price: int:
	get: return int(%Price.text)
	set(value): %Price.text = str(value)
