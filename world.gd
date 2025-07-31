extends Node2D

const CREATURE = preload("res://creature.tscn")

const BUNNY = preload("res://assets/bunny.png")
const GRASS = preload("res://assets/grass.png")
const WORM = preload("res://assets/worm.png")

const minimum_loop_size :int = 150

@onready var text_edit: TextEdit = %TextEdit

var creatures :Array[Creature]


func add_creature(nb:int,type:String):
	for i in nb:
		var new_creature := CREATURE.instantiate()
		add_child(new_creature)
		creatures.append(new_creature)
		new_creature.type = type
		if type == "bunny":
			new_creature.get_child(0).texture = BUNNY
		elif type == "worm":
			new_creature.get_child(0).texture = WORM
		else:
			new_creature.get_child(0).texture = GRASS
	
	var creature_amount = creatures.size()
	var i :int = 0
	for creature :Creature in creatures:
		var angle = (2 * PI * i) / creature_amount
		i+= 1
		creature.position.x = max(30*creature_amount,minimum_loop_size) * cos(angle)
		creature.position.y = max(30*creature_amount,minimum_loop_size) * sin(angle)


func _on_button_add_pressed() -> void:
	add_creature(1,text_edit.text)

func run_loop() -> void:
	for creature :Creature in creatures:
		#do creature's action here
		#creature.do_action
		pass
