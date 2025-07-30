extends Node2D

const CREATURE = preload("res://creature.tscn")

var creatures :Array[Creature]


func add_creature(nb:int):
	for i in nb:
		var new_creature := CREATURE.instantiate()
		add_child(new_creature)
		creatures.append(new_creature)
	
	var creature_amount = creatures.size()
	var i :int = 0
	for creature :Creature in creatures:
		var angle = (2 * PI * i) / creature_amount
		i+= 1
		creature.position.x = max(30*creature_amount,100) * cos(angle)
		creature.position.y = max(30*creature_amount,100) * sin(angle)


func _on_button_add_pressed() -> void:
	add_creature(1)
