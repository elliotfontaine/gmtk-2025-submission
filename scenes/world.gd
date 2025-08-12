extends Node2D


const CREATURE = preload("res://scenes/creature.tscn")
const EMPTY_SLOT = preload("res://scenes/empty_slot.tscn")

##change this value to dictate the creature size you want:
const initial_radius: float = 1.0 / 7
##change this value to dictate how much space the loop should take:
const zoom_factor: float = 0.7
const base_creature_distance: int = 60

const reroll_base_price: int = 10
const base_income: int = 50

@export_category(&"Gameplay")
@export var final_level: int = 20
@export_category(&"Sounds")
@export var sfx_next_loop: AudioStream
@export var sfx_suicide: AudioStream
@export var sfx_no_action: AudioStream
@export var sfx_game_over: AudioStream

@onready var camera: Camera2D = %Camera2D
@onready var floating_creature: Sprite2D = %FloatingCreature
@onready var label_score: Label = %LabelScore
@onready var creature_card: CreatureCard = %CreatureCard
@onready var progress_bar_score: ProgressBar = %ProgressBarScore
@onready var sfx_player: AudioStreamPlayer = $SFX_Player
@onready var initial_camera_zoom: float = camera.zoom.x
@onready var currency_count: Label = %CurrencyCount
@onready var shop_panel: ShopPanel = %ShopPanel
@onready var next_loop_button: Button = %NextLoopButton
@onready var defeat_ui: ColorRect = %DefeatScreen
@onready var defeat_loop_label: Label = %DefeatLoopLabel
@onready var victory_ui: Control = %VictoryScreen
@onready var victory_loop_label: Label = %VictoryLoopLabel
@onready var label_loop: Label = %LabelLoop
@onready var labelprevscore: Label = %Labelprevscore
@onready var h_box_tutorial: HBoxContainer = %HBoxTutorial
@onready var settings_menu: Control = %SettingsMenu
@onready var animation_player_score_bar: AnimationPlayer = %AnimationPlayerScoreBar


##placeholder system: length of wait times 
const game_speeds: Array[float] = [0.8, 0.4, 0.2, 0.1]
var game_speed: float = game_speeds[0]

var creatures: Array[Creature]

var empty_slots: Array[Node2D]

var iterator: int

var level: int = 0:
	set(val):
		level = val
		label_loop.text = "Loop #%s" % [level]

##placeholder system for naming the creatures
var creature_tracker: int = 0

# to prevent race condition coming from Area2D mouse_exited not triggering in order
## buffer used for SpeciesCard display when hovering loop creatures
var hovered_creature: Creature

var currently_looping: bool = false

var money: int = 50:
	set(val):
		assert(val >= 0)
		money = val
		currency_count.text = str(money)

func _ready() -> void:
	money = money # (to trigger label update)
	next_level()

##to call whenever you affect the number of creatures in the loop 
func update_creature_positions(show_empty_slots: bool = false) -> void:
	h_box_tutorial.hide()
	for slot in empty_slots:
		slot.queue_free()
	empty_slots.clear()
		
	var creature_amount: int = creatures.size()
	
	var radius: float = (get_viewport().get_visible_rect().size.y / 2.0) * creature_amount * initial_radius
	
	radius = max(radius, 200.0)
	
	if creature_amount == 1 && not show_empty_slots:
		creatures[0].position = Vector2.ZERO
	
	elif creature_amount == 0 && show_empty_slots:
		var new_slot := EMPTY_SLOT.instantiate()
		new_slot.pressed.connect(_on_slot_pressed)
		new_slot.index = 0
		add_child(new_slot)
		new_slot.position = Vector2.ZERO
		empty_slots.append(new_slot)
	
	else:
		var i: int = 0
		for creature: Creature in creatures:
			var angle = ((2 * PI * i) / creature_amount) - PI / 2
			creature.target_position.x = radius * cos(angle)
			creature.target_position.y = radius * sin(angle)
			
			i += 1
			creature.target_position.x = radius * cos(angle)
			creature.target_position.y = radius * sin(angle)
			
			if show_empty_slots:
				var new_slot := EMPTY_SLOT.instantiate()
				new_slot.pressed.connect(_on_slot_pressed)
				new_slot.index = i
				add_child(new_slot)
				new_slot.position.x = radius * cos(angle + (PI / creature_amount))
				new_slot.position.y = radius * sin(angle + (PI / creature_amount))
				empty_slots.append(new_slot)
	
	##adaptative zoom:
	var zoom: float = (get_viewport().get_visible_rect().size.y / 2.0) / radius * zoom_factor
	zoom = clampf(zoom, 0.0, 0.8)
	camera.zoom = Vector2(zoom, zoom)
	##screen is 1920, minus about 480 for the left panel.  Therefore the offset for the camera if screen is 1920 is (-480/2) = -240.
	##however is the camera's zoom is 0.5, then the offset should be (-480/2) * (1/0.5) = -480
	##therefore: camera.offset = (-480/2) * (1/camera.zoom)
	camera.offset.x = (-480 / 2) * (1 / camera.zoom.x)

func _on_next_loop_button_pressed() -> void:
	sfx_player.stream = sfx_next_loop
	sfx_player.play()
	if not currently_looping:
		currently_looping = true
		toggle_loop_button_text(false)
		shop_panel.modulate = Color.DIM_GRAY
		await run_loop()
		if score_current >= score_target:
			currently_looping = false
			money += base_income + (level * 2)
			if level == final_level:
				win()
			else:
				toggle_loop_button_text(true)
				shop_panel.modulate = Color.WHITE
				next_level()
		else:
			defeat()
	
	else:
		#set var before to prevent bug on multi-press:
		var current_speed_index = game_speeds.find(game_speed)
		if current_speed_index + 1 < game_speeds.size():
			game_speed = game_speeds[current_speed_index + 1]
		elif current_speed_index + 1 == game_speeds.size():
			game_speed = game_speeds[0]
		else:
			print("what??")
		toggle_loop_button_text(false)
	
func _on_continue_pressed() -> void:
	victory_ui.hide()
	toggle_loop_button_text(true)
	shop_panel.modulate = Color.WHITE
	next_level()
	
func run_loop() -> void:
	await do_on_loop_start_actions()
	
	iterator = 0
	while iterator < creatures.size():
		var creature = creatures[iterator]
		print("%s's turn" % [creature.name])
		creature.show_arrow(true)
		
		##do creature's actions here:
		#await get_tree().create_timer(game_speed / 2).timeout
		#score_current += 1
		await get_tree().create_timer(game_speed).timeout
		await do_action(creature)
		
		iterator += 1
		
		if creature:
			creature.show_arrow(false)
		await get_tree().create_timer(game_speed).timeout
	
	await do_on_loop_end_actions()
	
	print("scored this loop: ", score_current)

func toggle_loop_button_text(active: bool) -> void:
	if active:
		next_loop_button.text = "Run Loop"
	else:
		match game_speed:
			game_speeds[0]:
				next_loop_button.text = "x1"
			game_speeds[1]:
				next_loop_button.text = "x2"
			game_speeds[2]:
				next_loop_button.text = "x4"
			game_speeds[3]:
				next_loop_button.text = "x8"

func win() -> void:
	victory_loop_label.text = "Loop reached: %s" % [level]
	victory_ui.show()
	sfx_player.stream = sfx_game_over
	sfx_player.play()
	pass

func defeat() -> void:
	defeat_loop_label.text = "Loop reached: %s" % [level]
	defeat_ui.show()
	sfx_player.stream = sfx_game_over
	sfx_player.play()

#region creature action matchers

func do_action(creature: Creature) -> void:
	match creature.species.id:
		##if grass has no plant neighbours, it duplicates
		Constants.SPECIES.GRASS:
			if not check_neighbours_types(creature, creature.current_range, [Constants.FAMILIES.PLANT]):
				await duplicate_creature(creature)
				score_current += creature.species.score_reward_1
			else:
				do_no_action()
		##bunbun eats a plant then duplicates, if no plant, suicides
		Constants.SPECIES.BUNNY:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.PLANT], [Constants.SIZES.SMALL]):
				score_current += creature.species.score_reward_1
				await get_tree().create_timer(game_speed).timeout
				await update_creature_positions()
				await get_tree().create_timer(game_speed).timeout
				await duplicate_creature(creature)
			else:
				await suicide(creature)
				await get_tree().create_timer(game_speed).timeout
				await update_creature_positions()
		##fox eats a neighbouring small animal :) yum
		Constants.SPECIES.FOX:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.ANIMAL], [Constants.SIZES.SMALL]):
				score_current += creature.species.score_reward_1
				await get_tree().create_timer(game_speed).timeout
				await update_creature_positions()
				await get_tree().create_timer(game_speed).timeout
				if not check_neighbours_species(creature, creature.current_range, [Constants.SPECIES.FOX]):
					await duplicate_creature(creature)
			else:
				do_no_action()
		## hedgehog eats a plant. and cannot be eaten! (see exception in eat method)
		Constants.SPECIES.HEDGEHOG:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.PLANT], [Constants.SIZES.SMALL]):
				score_current += creature.species.score_reward_1
				await update_creature_positions()
				await get_tree().create_timer(game_speed).timeout
			else:
				do_no_action()
		##chimkin consumes an insect, if succesful creates an egg
		Constants.SPECIES.CHICKEN:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.ANIMAL], [Constants.SIZES.TINY]):
					await get_tree().create_timer(game_speed).timeout
					await update_creature_positions()
					await get_tree().create_timer(game_speed).timeout
					create(creature, Constants.SPECIES.EGG)
			else:
				do_no_action()
		##songbird eats an insect in a bigger range, if succesful he creates an egg and places it far away
		Constants.SPECIES.SONGBIRD:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.ANIMAL], [Constants.SIZES.TINY]):
				await get_tree().create_timer(game_speed).timeout
				await update_creature_positions()
				await get_tree().create_timer(game_speed).timeout
				create(creature, Constants.SPECIES.EGG, 3)
			else:
				do_no_action()
		##lynx eats both of its neighbours if possible :3 yum
		Constants.SPECIES.LYNX:
			var eaten: bool
			for neighbour in get_neighbours_in_range(creature, creature.current_range):
				if await attempt_to_eat_target(creature, neighbour, [Constants.FAMILIES.ANIMAL], [Constants.SIZES.SMALL]):
					score_current += creature.species.score_reward_1
					eaten = true
					await get_tree().create_timer(game_speed).timeout
					await update_creature_positions()
			if !eaten:
				do_no_action()
		##wolf is the basic medium generator, but may also be all-ined on to maximum its "pack" flavor bonus
		Constants.SPECIES.WOLF:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.ANIMAL], [Constants.SIZES.SMALL]):
				score_current += creature.species.score_reward_1 * (count_how_many_in_loop(Constants.SPECIES.WOLF))
				await get_tree().create_timer(game_speed).timeout
				await update_creature_positions()
			else:
				do_no_action()
		##tiger is the basic large predator - eats a medium dude in 2 range
		Constants.SPECIES.TIGER:
			if await eat_something_in_range(creature, creature.current_range, [Constants.FAMILIES.ANIMAL], [Constants.SIZES.MEDIUM]):
				score_current += creature.species.score_reward_1
				await get_tree().create_timer(game_speed).timeout
				await update_creature_positions()
			else:
				do_no_action()
		Constants.SPECIES.ANT:
			score_current += creature.species.score_reward_1 * count_how_many_connected(creature, creature.species.id)
		Constants.SPECIES.VIPER:
			money += creature.species.money_reward_1 * count_how_many_in_loop(Constants.SPECIES.EGG)
		Constants.SPECIES.OAK:
			await create_in_a_random_space_in_range(creature, Constants.SPECIES.ACORN, creature.species.default_range)
		Constants.SPECIES.SQUIRREL:
			var neighbours = get_neighbours_in_range(creature, creature.current_range)
			var furthest_small_plant_in_range: Creature
			for neighbour in neighbours:
				if neighbour.species.family == Constants.FAMILIES.PLANT and neighbour.species.size == Constants.SIZES.SMALL:
					furthest_small_plant_in_range = neighbour
			if furthest_small_plant_in_range:
				pull_to_creature(creature, furthest_small_plant_in_range)
		
		##if creature doesn't do anything: skip right away instead of extra wait time
		_:
			return
	
	await get_tree().create_timer(game_speed).timeout
	return

##whenever a creature is to be eaten, run this method to trigger all _on_eat effects after eating it
func do_on_eat_actions(eater: Creature, to_be_eaten: Creature) -> void:
	##first check which effects are triggered, then eat, then do the effects (so that the effects do happen AFTER eating while still being able to use the previous game state's parameters)
	var triggered_creatures: Array[Creature]
	
	##check triggers
	for creature in creatures:
		##actions for when something else is eaten:
		if not creature == to_be_eaten:
			match creature.species.id:
				##worm duplicates whenever an animal dies in its long range if not already adjacent to a worm:
				Constants.SPECIES.WORM:
					if to_be_eaten.species.family == Constants.FAMILIES.ANIMAL and to_be_eaten.species.size != Constants.SIZES.TINY:
						if get_distance_between_two_creatures(creature, to_be_eaten) <= creature.current_range:
							triggered_creatures.append(creature)
				## ant duplicates if the eaten one is an adjacent ant
				Constants.SPECIES.ANT:
					if to_be_eaten.species.id == Constants.SPECIES.ANT and to_be_eaten in get_neighbours_in_range(creature, 1):
						triggered_creatures.append(creature)
				##crow makes points whenever an animal dies in its long long range:
				Constants.SPECIES.CROW:
					if to_be_eaten.species.family == Constants.FAMILIES.ANIMAL and to_be_eaten.species.size != Constants.SIZES.TINY:
						if get_distance_between_two_creatures(creature, to_be_eaten) <= creature.current_range:
							triggered_creatures.append(creature)
		##actions for when the creature itself is eaten:
		else:
			##when eaten, egg gives extra yum!:
			match creature.species.id:
				Constants.SPECIES.EGG:
					score_current += creature.species.score_reward_1
				Constants.SPECIES.BERRY:
					score_current += creature.species.score_reward_1
	
	remove(to_be_eaten)
	await get_tree().create_timer(game_speed / 2).timeout
	
	##do triggered actions
	for creature in triggered_creatures:
		match creature.species.id:
			Constants.SPECIES.WORM:
				if not check_neighbours_species(creature, 1, [Constants.SPECIES.WORM]):
					await duplicate_creature(creature)
			Constants.SPECIES.ANT:
				await duplicate_creature(creature)
			Constants.SPECIES.CROW:
				score_current += creature.species.score_reward_1
				await get_tree().create_timer(game_speed / 2).timeout

##whenever a creature duplicates, trigger _on_duplicate effects
func do_on_duplicate_actions(duplicator: Creature) -> void:
	for creature in creatures:
		match creature.species.id:
			##Badger scores on duplicate
			Constants.SPECIES.BADGER:
				score_current += creature.species.score_reward_1

##called on loop start for start of loop effects
func do_on_loop_start_actions() -> void:
	SceneChanger.adaptive_music_player.tween_intensity(1.0)
	var triggered_creatures: Array[Creature]
	for creature in creatures:
		match creature.species.id:
			Constants.SPECIES.BUSH:
				triggered_creatures.append(creature)
			Constants.SPECIES.MOLE:
				triggered_creatures.append(creature)
	
	
	##do triggered actions
	for creature in triggered_creatures:
		match creature.species.id:
			Constants.SPECIES.BUSH:
				create(creature, Constants.SPECIES.BERRY, -1)
				create(creature, Constants.SPECIES.BERRY)
			Constants.SPECIES.MOLE:
				##known issue: the mole may pick its own position, but eh whatever I don't wanna risk new bugs
				await move_to(creature, randi() % creatures.size())
				await get_tree().create_timer(game_speed).timeout
				money += creature.species.money_reward_1
				

##called on loop end for end of loop effects
func do_on_loop_end_actions() -> void:
	var remove_queue: Array[Creature]
	for creature in creatures:
		match creature.species.id:
			##on loop end: if egg wasn't eaten or hatched or anything, it dies.
			Constants.SPECIES.EGG:
				remove_queue.append(creature)
			Constants.SPECIES.BERRY:
				remove_queue.append(creature)
			Constants.SPECIES.ACORN:
				score_current += creature.species.score_reward_1
				remove_queue.append(creature)
				await get_tree().create_timer(game_speed / 4).timeout
	
	for creature in remove_queue:
		if check_neighbours_species(creature, Constants.get_species_by_id(Constants.SPECIES.LADYBUG).default_range, [Constants.SPECIES.LADYBUG]):
			pass
		else:
			await remove(creature)
			await update_creature_positions()
			await get_tree().create_timer(game_speed).timeout

	SceneChanger.adaptive_music_player.tween_intensity(0.5)

#endregion

#region creature actions

##"who" attemps to eat a neighbour of the specified type in range
func eat_something_in_range(who: Creature, range: int, species_diet: Array[Constants.FAMILIES], size_diet: Array[Constants.SIZES]) -> bool:
	var neighbours: Array[Creature] = get_neighbours_in_range(who, range)
	var target: Creature
	for neighbour: Creature in neighbours:
		if check_if_fits_diet(neighbour, species_diet, size_diet):
			target = neighbour
			break
	if not target:
		return false
	else:
		await do_eat(who, target)
		return true

func attempt_to_eat_target(who: Creature, target: Creature, species_diet: Array[Constants.FAMILIES], size_diet: Array[Constants.SIZES]) -> bool:
	if check_if_fits_diet(target, species_diet, size_diet):
		await do_eat(who, target)
		return true
	else:
		return false

func check_if_fits_diet(target: Creature, species_diet, size_diet) -> bool:
	if target.species.family in species_diet && target.species.size in size_diet:
		if not target.species.id == Constants.SPECIES.HEDGEHOG:
			return true
	return false

##do eat the target
func do_eat(who: Creature, target: Creature) -> void:
	who.do_eat()
	
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
	
	await do_on_eat_actions(who, target)

##creature unalives itself spontaneously
func suicide(who: Creature) -> void:
	iterator -= 1
	remove(who)
	sfx_player.stream = sfx_suicide
	sfx_player.play()

func move(who: Creature, amount: int) -> void:
	pass

func move_to(who: Creature, where: int) -> void:
	creatures.erase(who)
	creatures.insert(where, who)
	await update_creature_positions()

func pull_to_creature(puller: Creature, pulled: Creature) -> void:
	var id_puller: int = creatures.find(puller)
	var id_pulled: int = creatures.find(pulled)
	if id_puller > id_pulled:
		move_to(pulled, id_puller - 1)
	else:
		move_to(pulled, id_puller + 1)

#endregion

#region creature creation and deletion

##if duplicated or created by a creature, origin should be the originator. If placed by player, origin should be the marker's position
func add_creature(nb: int, id: Constants.SPECIES, pos: int = -1, origin_position: Vector2 = Vector2.ZERO) -> void:
	for i in nb:
		var new_creature := CREATURE.instantiate()
		if pos == -1:
			creatures.append(new_creature)
		else:
			if pos > creatures.size():
				creatures.append(new_creature)
			else:
				pos = max(pos, 0)
				creatures.insert(pos, new_creature)
		new_creature.species = Constants.get_species_by_id(id)
		creature_tracker += 1
		new_creature.creature_name = str(new_creature.species.title) + " [" + str(creature_tracker) + "]"
		new_creature.position = origin_position
		add_child(new_creature)
		new_creature.mouse_entered.connect(_on_creature_mouse_entered.bind(new_creature))
		new_creature.mouse_exited.connect(_on_creature_mouse_exited.bind(new_creature))
		print("creating '%s' at position %s" % [new_creature.name, pos])
	
	await update_creature_positions()

##remove creature from loop
func remove(who: Creature) -> void:
	creatures.erase(who)
	who.queue_free()

##creates a new creature with the same species as the specified creature at its position - eg. it will place it before.
func duplicate_creature(who: Creature) -> void:
	await add_creature(1, who.species.id, creatures.find(who), who.position)
	await do_on_duplicate_actions(who)
	##if the duplicating creature is before the iterator, then you add iterator so it doesn't play twice, but if the duplicator is AFTER the iterator (like a worm, then don't +iterator as that would skip the next guy's turn
	var id: int = creatures.find(who)
	if id > iterator + 1:
		return
	iterator += 1
	return

##creates a new creature after who's position. Doesn't increment iterator.
func create(who: Creature, what: Constants.SPECIES, extra_range: int = 0) -> void:
	var pos: int = creatures.find(who) + 1 + extra_range
	if pos > creatures.size():
		pos = -1
	await add_creature(1, what, pos, who.position)

func create_in_a_random_space_in_range(who: Creature, what: Constants.SPECIES, range: int) -> void:
	var pos: int = creatures.find(who) + randi_range(1, range) * [-1, 1].pick_random()
	if pos >= iterator + 1:
		pass
	else:
		iterator += 1
	
	if pos > creatures.size():
		pos = -1
	await add_creature(1, what, pos, who.position)


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
			##start with negatives so that the neighbours start with the closest creature BEHIND, and then goes up by proximity, (eg. [-1, 1, -2, 2, ...])
			offsets.append(- (i + 1))
			offsets.append(i + 1)
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

func get_distance_between_two_creatures(one: Creature, two: Creature) -> int:
	if one and two:
		if one in creatures and two in creatures:
			var index_one = posmod(creatures.find(one), creatures.size())
			var index_two = posmod(creatures.find(two), creatures.size())
			var forward_distance = posmod(index_two - index_one, creatures.size())
			var backward_distance = posmod(index_one - index_two, creatures.size())
			var distance: int = min(forward_distance, backward_distance)
			return distance
	return 999

func count_how_many_in_loop(what: Constants.SPECIES) -> int:
	var count: int = 0
	for creature in creatures:
		if creature.species.id == what:
			count += 1
	return count

##counts itself then backwards then forwards and wraps around if needed and blabla
func count_how_many_connected(who: Creature, what: Constants.SPECIES) -> int:
	var count: int = 1
	var pos: int = creatures.find(who)
	#count those frontwards
	for i in range(1, creatures.size()):
		if pos + i < creatures.size():
			if creatures[i + pos].species.id == what:
				count += 1
			else:
				break
		else:
			if creatures[i + pos - creatures.size()].species.id == what:
				count += 1
			else:
				break
	
	for i in range(1, creatures.size()):
		if pos - i >= 0:
			if creatures[-i + pos].species.id == what:
				count += 1
			else:
				break
		else:
			if creatures[-i + pos + creatures.size()].species.id == what:
				count += 1
			else:
				break
	
	print(count, " in a row")
	##if the whole loop is only made up of what: only return the length of the loop:
	return min(count, creatures.size())

#endregion

#region score manager

var score_target: int
var score_current: int:
	set(val):
		score_current = val
		update_score_display()

func next_level():
	level += 1
	if score_current > 0:
		labelprevscore.show()
		labelprevscore.text = "previous score: " + str(score_current)
	else:
		labelprevscore.hide()
	score_current = 0
	score_target = level * 1 * maxi(level / 3.0, 1) + maxi(0, (level - 2) * 3)
	progress_bar_score.max_value = score_target
	update_score_display()
	
	shop_panel.level = level
	reroll_price = 10
	shop_panel.re_roll.text = "REROLL:" + str(reroll_price)
	shop_panel.populate_shop()

func update_score_display() -> void:
	label_score.text = "SCORE: %s / %s" % [score_current, score_target]
	progress_bar_score.value = score_current # would be nice to add some lerp to this
	if score_current >= score_target and score_current != 0:
		if animation_player_score_bar.assigned_animation not in [&"winning", &"winning_idle"]:
			animation_player_score_bar.play(&"winning")
			animation_player_score_bar.queue(&"winning_idle")
	else:
		animation_player_score_bar.play(&"RESET", 0.5)

#endregion

#region creature_card manager
func _on_shop_panel_item_hovered(species: SpeciesResource) -> void:
	if floating_creature.species == null:
		creature_card.species = species

func _on_shop_panel_item_exited() -> void:
	if floating_creature.species == null:
		creature_card.species = null

func _on_creature_mouse_entered(creature: Creature) -> void:
	if floating_creature.species == null:
		hovered_creature = creature
		creature_card.species = creature.species

func _on_creature_mouse_exited(creature: Creature) -> void:
	if floating_creature.species == null:
		if creature == hovered_creature:
			creature_card.species = null
		else:
			return # because that mean another thing already got hovered
#endregion

#region floating_creature manager
func set_floating_creature(species) -> void:
	floating_creature.species = species
	creature_card.species = species
	update_creature_positions(true)

func unset_floating_creature() -> void:
	floating_creature.species = null
	creature_card.species = null
	update_creature_positions(false)

func _on_shop_panel_floating_creature_asked(item: ShopItem) -> void:
	if not currently_looping:
		if money >= item.price:
			current_held_item = item
			current_item_price = item.price
			set_floating_creature(item.species)
		else:
			pass

func _on_slot_pressed(index: int) -> void:
	if not currently_looping:
		if floating_creature.species != null:
			money -= current_item_price
			if current_held_item and not shop_panel.creative:
				current_held_item.sold = true
				print(current_held_item.sold)
			add_creature(1, floating_creature.species.id, index, empty_slots[index - 1].position)
			unset_floating_creature()

func _unhandled_input(event):
	if floating_creature.species != null:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			unset_floating_creature()
#endregion

#region money management

var current_item_price: int = 0
var current_held_item: ShopItem

var reroll_price: int = reroll_base_price

func _on_shop_panel_rerolled() -> void:
	if not currently_looping:
		if money >= reroll_price:
			money -= reroll_price
			shop_panel.do_reroll()
			
			reroll_price = int(reroll_price * 1.2)
			shop_panel.re_roll.text = "REROLL:" + str(reroll_price)

#endregion


func _on_retry_pressed() -> void:
	SceneChanger.change_to(SceneChanger.MainScenes.WORLD)


func _on_exit_pressed() -> void:
	SceneChanger.change_to(SceneChanger.MainScenes.MAIN)

func do_no_action():
	sfx_player.stream = sfx_no_action
	sfx_player.play()

func _on_settings_button_pressed() -> void:
	settings_menu.show()

func _on_timer_bop_timeout() -> void:
	if not currently_looping:
		if creatures:
			var rand_crea: Creature = creatures.pick_random()
			if rand_crea:
				rand_crea.play_bop()
