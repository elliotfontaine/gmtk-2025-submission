extends Node2D

const CREATURE = preload("res://creature.tscn")

const minimum_loop_size :int = 150

@onready var camera_2d: Camera2D = %Camera2D

var creatures :Array[Creature]

var iterator :int

func add_creature(nb:int,data:SpeciesData,pos:int=-1) -> void:
	for i in nb:
		var new_creature := CREATURE.instantiate()
		if pos == -1:
			creatures.append(new_creature)
		else:
			creatures.insert(pos,new_creature)
			iterator += 1
		new_creature.data = data
		new_creature.get_child(0).texture = data.texture
		new_creature.name = str(creatures.size())
		add_child(new_creature)
		print("creating %s at %s"%[new_creature.name,pos])
	
	update_creature_positions()


##to call whenever you affect the number of creatures in the loop 
func update_creature_positions() -> void:
	var creature_amount = creatures.size()
	var i :int = 0
	for creature :Creature in creatures:
		var angle = ((2 * PI * i) / creature_amount) - PI/2
		i+= 1
		creature.position.x = max(30*creature_amount,minimum_loop_size) * cos(angle)
		creature.position.y = max(30*creature_amount,minimum_loop_size) * sin(angle)
	
	##adaptative zoom: to adjust further once we have a better idea of the size of assets
	var zoom :float = max(1.0 - (0.015 * creature_amount),0.3)
	camera_2d.zoom = Vector2(zoom,zoom)

func _ready() -> void:
	add_creature(1,load("res://species_info/grass.tres"))
	add_creature(1,load("res://species_info/worm.tres"))
	add_creature(1,load("res://species_info/grass.tres"))
	add_creature(1,load("res://species_info/bunny.tres"))
	add_creature(1,load("res://species_info/fox.tres"))
	add_creature(1,load("res://species_info/bunny.tres"))


func _on_button_add_pressed() -> void:
	#add_creature(1,load("res://species_info/bunny.tres"))
	add_creature(1,load("res://species_info/grass.tres"))

func _on_button_run_pressed() -> void:
	run_loop()

func run_loop() -> void:
	iterator = 0
	while iterator < creatures.size():
		var creature = creatures[iterator]
		creature.modulate = Color.RED
		await get_tree().create_timer(1.0).timeout
		print(creature.name)
		##do creature's actions here
		match creature.data.id:
			##bunbun eats a plant then duplicates, if no plant, suicides
			"bunny":
				if eat(creature,1,[SpeciesData.TYPES.plant]):
					await get_tree().create_timer(1.0).timeout
					update_creature_positions()
					await get_tree().create_timer(1.0).timeout
					add_creature(1,load("res://species_info/bunny.tres"),creatures.find(creature))
					await get_tree().create_timer(1.0).timeout
				else:
					suicide(creature)
					await get_tree().create_timer(1.0).timeout
					update_creature_positions()
					await get_tree().create_timer(1.0).timeout
			##if grass has no plant neighbours, it duplicates
			"grass":
				if not check_neighbours_types(creature,1,[SpeciesData.TYPES.plant]):
					add_creature(1,load("res://species_info/grass.tres"),creatures.find(creature))
					await get_tree().create_timer(1.0).timeout
			#fox eats a neighbouring small animal :) yum
			"fox":
				if eat(creature,1,[SpeciesData.TYPES.animal]):
					await get_tree().create_timer(1.0).timeout
					update_creature_positions()
					await get_tree().create_timer(1.0).timeout
		if creature:
			creature.modulate = Color.WHITE
		iterator += 1

##"who" eats neighbours of the specified type in range
func eat(who:Creature,range:int,diet:Array[SpeciesData.TYPES]) -> bool:
	var neighbours :Array[Creature] = get_neighbours_in_range(who,range)
	var target :Creature
	for creature :Creature in neighbours:
		if creature.data.type in diet:
			target = creature
	if target:
		var index_who = posmod(creatures.find(who), creatures.size())
		var index_tar = posmod(creatures.find(target), creatures.size())
		var forward_distance = posmod(index_tar - index_who, creatures.size())
		var backward_distance = posmod(index_who - index_tar, creatures.size())
		if forward_distance <= backward_distance:
			pass
		else:
			iterator -= 1
		
		remove(target)
		
		return true
	else:
		return false

##creature unalives itself spontaneously
func suicide(who:Creature) -> void:
	iterator -= 1
	remove(who)

##remove creature from loop
func remove(who:Creature) -> void:
	creatures.erase(who)
	who.queue_free()

##checks whether "who" has a neighbour of "condition" type
func check_neighbours_types(who:Creature,range:int,condition:Array[SpeciesData.TYPES]) -> bool:
	var neighbours :Array[Creature] = get_neighbours_in_range(who,range)
	var target :Creature
	for creature :Creature in neighbours:
		if creature.data.type in condition:
			return true
	return false

func get_neighbours_in_range(who:Creature,range:int) -> Array[Creature]:
	var origin :int = creatures.find(who)
	var targets_in_range :Array[Creature]
	print("getting %s's neighbours:"%[who.name])
	##exception if range covers the whole loop:
	if range*2 >= creatures.size():
		targets_in_range = creatures.duplicate()
		targets_in_range.erase(who)
	else:
		for i :int in range:
			for sign :int in [-1,1]:
				#print(i)
				var position_to_check :int = origin + ((i+1)*sign)
				#print(position_to_check)
				##regular
				if position_to_check < creatures.size() and position_to_check >= 0:
					pass
				##wrap around on the rightmost edge of the array:
				elif position_to_check >= 0:
					position_to_check -= creatures.size()
				##wrap around on the leftmost edge of the array:
				elif position_to_check < creatures.size():
					position_to_check += creatures.size()
				
				#print("  ->",position_to_check)
				if not creatures[position_to_check] in targets_in_range:
					targets_in_range.append(creatures[position_to_check])
	#print(targets_in_range)
	return targets_in_range
