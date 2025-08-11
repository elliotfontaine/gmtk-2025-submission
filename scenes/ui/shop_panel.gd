class_name ShopPanel extends PanelContainer

signal floating_creature_asked(item: ShopItem)
signal item_hovered(species: SpeciesResource)
signal item_exited
signal rerolled

## Creative for the shop means you can add any registered creature for free
@export var creative: bool = false

@onready var grid_container := %GridContainer
@onready var sfx_click: AudioStreamPlayer = %SFX_Click
@onready var re_roll: Button = %ReRoll

const ITEM_SCENE := preload("res://scenes/ui/shop_item.tscn")

var level: int


func _on_item_hovered(item: ShopItem) -> void:
	# TODO: show "- Price" after currency count
	if not item.sold:
		item_hovered.emit(item.species)

func _on_item_exited() -> void:
	item_exited.emit()

func _on_item_pressed(item: ShopItem) -> void:
	floating_creature_asked.emit(item) # connected in inspector
	sfx_click.play()

func _on_re_roll_pressed() -> void:
	rerolled.emit() # connected in inspector to world

##called by world
func do_reroll() -> void:
	populate_shop()

func populate_shop() -> void:
	clear_items()
	var species_list: Array[Constants.SPECIES] = generate_species_list()
	for id in species_list:
		add_shop_item(generate_item_from_species_id(id))

func add_shop_item(shop_item: ShopItem) -> void:
	grid_container.add_child(shop_item)
	shop_item.mouse_entered.connect(_on_item_hovered.bind(shop_item))
	shop_item.mouse_exited.connect(_on_item_exited)
	shop_item.pressed.connect(_on_item_pressed.bind(shop_item))

func get_shop_items() -> Array[ShopItem]:
	var items: Array[ShopItem]
	items.assign(grid_container.get_children())
	return items

func clear_items() -> void:
	for item: ShopItem in get_shop_items():
		grid_container.remove_child(item)
		item.queue_free()

func generate_item_from_species_id(species_id: int) -> ShopItem:
	var species: SpeciesResource = Constants.get_species_by_id(species_id)
	var new_item: ShopItem = ITEM_SCENE.instantiate()
	new_item.species = species
	if creative:
		new_item.price = 0
	else:
		var base_price: int
		match new_item.species.rarity:
			Constants.RARITIES.COMMON:
				base_price = 20
			Constants.RARITIES.UNCOMMON:
				base_price = 28
			Constants.RARITIES.RARE:
				base_price = 36
			Constants.RARITIES.EPIC:
				base_price = 44
			#Constants.RARITIES.LEGENDARY:
				#base_price = 40
			_:
				base_price = 0
		new_item.price = int((base_price + base_price * (level / 20.0)) * randf_range(0.85, 1.15))
	return new_item

func generate_species_list() -> Array[Constants.SPECIES]:
	var species_list: Array[Constants.SPECIES]
	
	if creative:
		species_list.assign(Constants.SPECIES.values()) # assign to avoid static typing issue (bug?)
		return species_list
	
	var rarities_and_weights := {}
	
	match level:
		1:
			re_roll.hide()
			return [Constants.SPECIES.GRASS]
		2:
			return [Constants.SPECIES.BUNNY]
		3:
			re_roll.show()
			rarities_and_weights = {Constants.RARITIES.COMMON: 1.0}
		4, 5:
			rarities_and_weights = {Constants.RARITIES.COMMON: 0.80, Constants.RARITIES.UNCOMMON: 0.20}
		6:
			rarities_and_weights = {Constants.RARITIES.COMMON: 0.70, Constants.RARITIES.UNCOMMON: 0.20, Constants.RARITIES.RARE: 0.10}
		7, 8:
			rarities_and_weights = {Constants.RARITIES.COMMON: 0.55, Constants.RARITIES.UNCOMMON: 0.30, Constants.RARITIES.RARE: 0.15}
		9, 10:
			rarities_and_weights = {Constants.RARITIES.COMMON: 0.50, Constants.RARITIES.UNCOMMON: 0.25, Constants.RARITIES.RARE: 0.25}
		_:
			rarities_and_weights = {Constants.RARITIES.COMMON: 0.50, Constants.RARITIES.UNCOMMON: 0.25, Constants.RARITIES.RARE: 0.25}
	
	species_list = pick_species_randomly(rarities_and_weights, 6)
	species_list.shuffle()
	return species_list

##takes in a dictionary of weights associated to rarities, then rolls to pick one
func pick_species_randomly(rarities_and_weights: Dictionary, amount: int) -> Array[Constants.SPECIES]:
	var species_list: Array[Constants.SPECIES] = []
	var rarities_dict := {}
	
	var cumulative_weights := []
	var total_weight := 0.0

	for rarity in rarities_and_weights.keys():
		total_weight += rarities_and_weights[rarity]
		cumulative_weights.append(total_weight)

	for i in range(amount):
		
		var roll = randf() * total_weight
		
		for id in range(cumulative_weights.size()):
			if roll <= cumulative_weights[id]:
				var rarity = rarities_and_weights.keys()[id]
				rarities_dict[rarity] = rarities_dict.get(rarity, 0) + 1
				break

	for rarity in rarities_dict.keys():
		species_list.append_array(pick_species_by_rarity([rarity], rarities_dict[rarity]))

	return species_list


func pick_species_by_rarity(rarity: Array[Constants.RARITIES], amount: int = 0) -> Array[Constants.SPECIES]:
	var queried_species: Array[Constants.SPECIES]
	
	for specie: Constants.SPECIES in Constants.SPECIES.values():
		if Constants.get_species_by_id(specie).rarity in rarity:
			queried_species.append(specie)
	
	if not amount == 0:
		var select_species: Array[Constants.SPECIES]
		for i in amount:
			if queried_species.size() > 0:
				var rand_specie: Constants.SPECIES = queried_species.pick_random()
				select_species.append(rand_specie)
		return select_species
	else:
		return queried_species
