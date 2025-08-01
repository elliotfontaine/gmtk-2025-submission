class_name World
extends Node2D

const CREATURE = preload("res://scenes/creature.tscn")
const EMPTY_SLOT = preload("res://scenes/empty_slot.tscn")

const minimum_loop_size: int = 150

@onready var camera_2d: Camera2D = %Camera2D
@onready var floating_creature: Sprite2D = %FloatingCreature
@onready var label_score: Label = %LabelScore
@onready var progress_bar_score: ProgressBar = %ProgressBarScore

##placeholder system: length of wait times 
var game_speed: float = 1.0

var creatures: Array[Creature]

var empty_slots: Array[Node2D]

var iterator: int

var level: int = 0

func add_creature(nb: int, id: Constants.SPECIES, pos: int = -1) -> void:
	for i in nb:
		var new_creature := CREATURE.instantiate()
		if pos == -1:
			creatures.append(new_creature)
		else:
			creatures.insert(pos, new_creature)
			iterator += 1
		new_creature.species = Constants.get_species_by_id(id)
		new_creature.get_child(0).texture = new_creature.species.texture
		new_creature.name = str(creatures.size())
		add_child(new_creature)
		print("creating %s at %s" % [new_creature.name, pos])
	
	update_creature_positions()


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

func _ready() -> void:
	next_level()

func _unhandled_input(event):
	if floating_creature.species != null:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			unset_floating_creature()

func _on_next_loop_button_pressed() -> void:
	await run_loop()
	next_level()

func _on_shop_panel_floating_creature_asked(species: SpeciesResource) -> void:
	set_floating_creature(species)

func _on_slot_pressed(index: int) -> void:
	if floating_creature.species != null:
		add_creature(1, floating_creature.species.id, index)
		unset_floating_creature()

func run_loop() -> void:
	iterator = 0
	while iterator < creatures.size():
		var creature = creatures[iterator]
		creature.modulate = Color.RED
		print("%s's turn" % [creature.name])
		await get_tree().create_timer(game_speed / 2).timeout
		score_current += 1
		await get_tree().create_timer(game_speed).timeout
		
		##do creature's actions here:
		if creature.species.has_action():
			await creature.species.action.execute(creature, self)
		else:
			print_debug("Creature %s has no action !" % creature)
		
		await get_tree().create_timer(game_speed).timeout
		if creature:
			creature.modulate = Color.WHITE
		iterator += 1

##"who" eats neighbours of the specified type in range
func eat(who: Creature, range: int, diet: Array[Constants.FAMILIES]) -> bool:
	var neighbours: Array[Creature] = get_neighbours_in_range(who, range)
	var target: Creature
	for creature: Creature in neighbours:
		if creature.species.family in diet:
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
func suicide(who: Creature) -> void:
	iterator -= 1
	remove(who)

##remove creature from loop
func remove(who: Creature) -> void:
	creatures.erase(who)
	who.queue_free()
	update_creature_positions()

##checks whether "who" has a neighbour of "condition" family
func check_neighbours_types(who: Creature, range: int, condition: Array[Constants.FAMILIES]) -> bool:
	var neighbours: Array[Creature] = get_neighbours_in_range(who, range)
	for creature: Creature in neighbours:
		if creature.species.family in condition:
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
#endregion
