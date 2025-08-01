extends Node2D
@export var background_music: AudioStream
@export var sfx_next_loop: AudioStream

const CREATURE = preload("res://scenes/creature.tscn")
const EMPTY_SLOT = preload("res://scenes/empty_slot.tscn")

const minimum_loop_size: int = 150

@onready var camera_2d: Camera2D = %Camera2D
@onready var floating_creature: Sprite2D = %FloatingCreature
@onready var label_score: Label = %LabelScore
@onready var progress_bar_score: ProgressBar = %ProgressBarScore
@onready var sfx_player: AudioStreamPlayer2D = $SFX_Player

##placeholder system: length of wait times 
var game_speed: float = 1.0

var creatures: Array[Creature]

var empty_slots: Array[Node2D]

var iterator: int

var level: int = 0

##placeholder system for naming the creatures
var creature_tracker :int = 0

func _ready() -> void:
	next_level()

##to call whenever you affect the number of creatures in the loop 
func update_creature_positions(show_empty_slots: bool = false) -> void:
	for slot in empty_slots:
		slot.queue_free()
	empty_slots.clear()
	
	var creature_amount = creatures.size()
	var i: int = 0
	for creature: Creature in creatures:
		var angle = ((2 * PI * i) / creature_amount) - PI / 2
		i += 1
		creature.position.x = max(30 * creature_amount, minimum_loop_size) * cos(angle)
		creature.position.y = max(30 * creature_amount, minimum_loop_size) * sin(angle)
		
		if show_empty_slots:
			var new_slot := EMPTY_SLOT.instantiate()
			new_slot.pressed.connect(_on_slot_pressed)
			new_slot.index = i
			add_child(new_slot)
			new_slot.position.x = max(30 * creature_amount, minimum_loop_size) * cos(angle + (PI / creature_amount))
			new_slot.position.y = max(30 * creature_amount, minimum_loop_size) * sin(angle + (PI / creature_amount))
			empty_slots.append(new_slot)
	
	if creature_amount == 0 && show_empty_slots:
		var new_slot := EMPTY_SLOT.instantiate()
		new_slot.pressed.connect(_on_slot_pressed)
		new_slot.index = 0
		add_child(new_slot)
		new_slot.position = Vector2.ZERO
		empty_slots.append(new_slot)
	
	##adaptative zoom: to adjust further once we have a better idea of the size of assets
	var zoom: float = max(1.0 - (0.015 * creature_amount), 0.3)
	camera_2d.zoom = Vector2(zoom, zoom)

func _on_next_loop_button_pressed() -> void:
	sfx_player.stream = sfx_next_loop
	sfx_player.play()
	await run_loop()
	next_level()

func run_loop() -> void:
	iterator = 0
	while iterator < creatures.size():
		var creature = creatures[iterator]
		print("%s's turn" % [creature.name])
		creature.modulate = Color.RED
		
		##do creature's actions here:
		await get_tree().create_timer(game_speed / 2).timeout
		score_current += 1
		await get_tree().create_timer(game_speed / 2).timeout
		await do_action(creature)
		
		iterator += 1
		
		if creature:
			creature.modulate = Color.WHITE
		await get_tree().create_timer(game_speed).timeout
	
	await do_on_loop_end_actions()

#region creature actions

func do_action(creature:Creature) -> void:
	match creature.species.id:
		##bunbun eats a plant then duplicates, if no plant, suicides
		Constants.SPECIES.BUNNY:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.PLANT], [Constants.SIZES.SMALL]):
				score_current += 5
				await get_tree().create_timer(game_speed).timeout
				await update_creature_positions()
				await get_tree().create_timer(game_speed).timeout
				await duplicate_creature(creature)
			else:
				await suicide(creature)
				await get_tree().create_timer(game_speed).timeout
				await update_creature_positions()
		##if grass has no plant neighbours, it duplicates
		Constants.SPECIES.GRASS:
			if not check_neighbours_types(creature, creature.current_range, [Constants.FAMILIES.PLANT]):
				await duplicate_creature(creature)
				score_current += 2
		##fox eats a neighbouring small animal :) yum
		Constants.SPECIES.FOX:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.ANIMAL], [Constants.SIZES.SMALL]):
				score_current += 7
				await get_tree().create_timer(game_speed).timeout
				await update_creature_positions()
		## hedgehog eats a plant. and cannot be eaten! (see exception in eat method)
		Constants.SPECIES.HEDGEHOG:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.PLANT], [Constants.SIZES.SMALL]):
				score_current += 4
				await get_tree().create_timer(game_speed).timeout
				await update_creature_positions()
		##chimkin consumes an insect, if succesful creates an egg
		Constants.SPECIES.CHICKEN:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.ANIMAL], [Constants.SIZES.TINY]):
					await get_tree().create_timer(game_speed).timeout
					await update_creature_positions()
					await get_tree().create_timer(game_speed).timeout
					create(creature,Constants.SPECIES.EGG)
		##songbird eats an insect in a bigger range, if succesful he creates an egg and places it far away
		Constants.SPECIES.SONGBIRD:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.ANIMAL], [Constants.SIZES.TINY]):
				await get_tree().create_timer(game_speed).timeout
				await update_creature_positions()
				await get_tree().create_timer(game_speed).timeout
				create(creature,Constants.SPECIES.EGG,3)
		##lynx eats both of its neighbours if possible :3 yum
		Constants.SPECIES.LYNX:
			for neighbour in get_neighbours_in_range(creature,creature.current_range):
				if await attempt_to_eat_target(creature, neighbour, [Constants.FAMILIES.ANIMAL], [Constants.SIZES.SMALL]):
					score_current += 9
					await get_tree().create_timer(game_speed).timeout
					await update_creature_positions()
	
	await get_tree().create_timer(game_speed).timeout
	return

##whenever a creature is to be eaten, run this method to trigger all _on_eat effects after eating it
func do_on_eat_actions(eater:Creature,to_be_eaten:Creature) -> void:
	##first check which effects are triggered, then eat, then do the effects (so that the effects do happen AFTER eating while still being able to use the previous game state's parameters)
	var triggered_creatures :Array[Creature]
	
	##check triggers
	for creature in creatures:
		##actions for when something else is eaten:
		if not creature == to_be_eaten:
			match creature.species.id:
				##worm duplicates whenever an animal dies in its long range if not already adjacent to a worm:
				Constants.SPECIES.WORM:
					if to_be_eaten.species.family == Constants.FAMILIES.ANIMAL:
						if get_distance_between_two_creatures(creature,to_be_eaten) <= creature.current_range:
							triggered_creatures.append(creature)
				##crow makes points whenever an animal dies in its long long range:
				Constants.SPECIES.CROW:
					if to_be_eaten.species.family == Constants.FAMILIES.ANIMAL:
						if get_distance_between_two_creatures(creature,to_be_eaten) <= creature.current_range:
							triggered_creatures.append(creature)
		##actions for when the creature itself is eaten:
		else:
			##when eaten, egg gives extra yum!:
			match creature.species.id:
				Constants.SPECIES.EGG:
					score_current += 5
	
	
	remove(to_be_eaten)
	await get_tree().create_timer(game_speed / 2).timeout
	
	##do triggered actions
	for creature in triggered_creatures:
		match creature.species.id:
			Constants.SPECIES.WORM:
				if not check_neighbours_species(creature, 1, [Constants.SPECIES.WORM]):
					await duplicate_creature(creature)
			Constants.SPECIES.CROW:
				score_current += 3
				await get_tree().create_timer(game_speed / 2).timeout
				

##called on loop end for end of loop effects
func do_on_loop_end_actions() -> void:
	for creature in creatures:
		match creature.species.id:
			##on loop end: if egg wasn't eaten or hatched or anything, it dies.
			Constants.SPECIES.EGG:
				remove(creature)
				await update_creature_positions()
				await get_tree().create_timer(game_speed).timeout


##"who" attemps to eat a neighbour of the specified type in range
func eat_something_in_range(who: Creature, range: int, species_diet: Array[Constants.FAMILIES], size_diet: Array[Constants.SIZES]) -> bool:
	var neighbours: Array[Creature] = get_neighbours_in_range(who, range)
	var target: Creature
	for neighbour: Creature in neighbours:
		if check_if_fits_diet(neighbour,species_diet,size_diet):
			target = neighbour
	if not target:
		return false
	else:
		await do_eat(who,target)
		return true

func attempt_to_eat_target(who: Creature, target:Creature, species_diet: Array[Constants.FAMILIES], size_diet: Array[Constants.SIZES]) -> bool:
	if check_if_fits_diet(target,species_diet,size_diet):
		await do_eat(who,target)
		return true
	else:
		return false

func check_if_fits_diet(target:Creature,species_diet,size_diet) -> bool:
	if target.species.family in species_diet && target.species.size in size_diet:
		if not target.species.id == Constants.SPECIES.HEDGEHOG:
			return true
	return false

##do eat the target
func do_eat(who:Creature,target:Creature) -> void:
	var index_who = posmod(creatures.find(who), creatures.size())
	var index_tar = posmod(creatures.find(target), creatures.size())
	var forward_distance = posmod(index_tar - index_who, creatures.size())
	var backward_distance = posmod(index_who - index_tar, creatures.size())
	if forward_distance <= backward_distance:
		print("ate in front")
		pass
	else:
		print("ate behind")
		##if target has already played, then regress iterator, but if target is in the future, no need to change the iterator because the creatures array did not shift
		if not index_tar > index_who:
			iterator -= 1
	
	await do_on_eat_actions(who,target)

##creature unalives itself spontaneously
func suicide(who: Creature) -> void:
	iterator -= 1
	remove(who)

#endregion

#region creature creation and deletion

func add_creature(nb: int, id: Constants.SPECIES, pos: int = -1) -> void:
	for i in nb:
		var new_creature := CREATURE.instantiate()
		if pos == -1:
			creatures.append(new_creature)
		else:
			creatures.insert(pos, new_creature)
		new_creature.species = Constants.get_species_by_id(id)
		new_creature.get_child(0).texture = new_creature.species.texture
		creature_tracker += 1
		new_creature.name = str(new_creature.species.title) +" " + str(creature_tracker)
		add_child(new_creature)
		print("creating %s at %s" % [new_creature.name, pos])
	
	await update_creature_positions()

##remove creature from loop
func remove(who: Creature) -> void:
	creatures.erase(who)
	who.queue_free()

##creates a new creature with the same species as the specified creature at its position - eg. it will place it before.
func duplicate_creature(who: Creature) -> void:
	await add_creature(1, who.species.id, creatures.find(who))
	iterator += 1
	return

##creates a new creature after who's position. Doesn't increment iterator.
func create(who: Creature, what:Constants.SPECIES,extra_range:int=0) -> void:
	var pos :int = creatures.find(who)+1+extra_range
	if pos > creatures.size():
		pos = -1
	await add_creature(1, what, creatures.find(who)+1+extra_range)

#endregion

#region creatures array querying 

##checks whether "who" has a neighbour of "condition" family
func check_neighbours_types(who: Creature, range: int, condition: Array[Constants.FAMILIES]) -> bool:
	var neighbours: Array[Creature] = get_neighbours_in_range(who, range)
	for creature: Creature in neighbours:
		if creature.species.family in condition:
			return true
	return false
	
##checks whether "who" has a neighbour of "condition" species
func check_neighbours_species(who: Creature, range: int, condition: Array[Constants.SPECIES]) -> bool:
	var neighbours: Array[Creature] = get_neighbours_in_range(who, range)
	for creature: Creature in neighbours:
		if creature.species.id in condition:
			return true
	return false

func get_neighbours_in_range(who: Creature, range: int) -> Array[Creature]:
	var origin: int = creatures.find(who)
	var targets_in_range: Array[Creature]
	print("getting %s's neighbours:" % [who.name])
	##exception if range covers the whole loop:
	if range * 2 >= creatures.size():
		targets_in_range = creatures.duplicate()
		targets_in_range.erase(who)
	else:
		var offsets := []
		for i in range:
			offsets.append(i + 1)
			offsets.append(-(i + 1))
		print(offsets)
		for offset in offsets:
			#print(offset)
			var position_to_check: int = origin + offset
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

func get_distance_between_two_creatures(one:Creature,two:Creature) -> int:
	if one and two:
		if one in creatures and two in creatures:
			var index_one = posmod(creatures.find(one), creatures.size())
			var index_two = posmod(creatures.find(two), creatures.size())
			var forward_distance = posmod(index_two - index_one, creatures.size())
			var backward_distance = posmod(index_one - index_two, creatures.size())
			var distance :int = min(forward_distance,backward_distance)
			return distance
	return 999

#endregion

#region score manager

var score_target: int
var score_current: int:
	set(val):
		score_current = val
		update_score_display()

func next_level():
	level += 1
	score_current = 0
	score_target = level * 10 * maxi(level / 3, 1) + maxi(0, (level - 2) * 3)
	progress_bar_score.max_value = score_target
	update_score_display()

func update_score_display() -> void:
	label_score.text = "SCORE: %s / %s" % [score_current, score_target]
	progress_bar_score.value = score_current

#endregion

#region floating_creature manager
func set_floating_creature(species) -> void:
	floating_creature.species = species
	update_creature_positions(true)

func unset_floating_creature() -> void:
	floating_creature.species = null
	update_creature_positions(false)

func _on_shop_panel_floating_creature_asked(species: SpeciesResource) -> void:
	set_floating_creature(species)

func _on_slot_pressed(index: int) -> void:
	if floating_creature.species != null:
		add_creature(1, floating_creature.species.id, index)
		unset_floating_creature()

func _unhandled_input(event):
	if floating_creature.species != null:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			unset_floating_creature()

#endregion
