extends PanelContainer
class_name ShopPanel

signal floating_creature_asked(item: ShopItem)
signal item_hovered(species: SpeciesResource)
signal item_exited
signal rerolled

## Creative for the shop means you can add any registered creature for free
@export var creative: bool = false
## Should the creature count stop at the 6 first instead of all registered
@export var stop_at_six: bool = false

@onready var grid_container := %GridContainer
@onready var sfx_click: AudioStreamPlayer = %SFX_Click
@onready var re_roll: Button = %ReRoll

const ITEM_SCENE := preload("res://scenes/ui/shop_item.tscn")

var level: int

func _ready() -> void:
	if creative:
		clear_items()
		populate_creative_shop()
	else:
		pass # World will trigger shop populating
		#populate_shop()
		# TODO: iDK, I guess maybe it should me managed by the World Scene, since
		# it's gonna fill it mutiple times.

func _on_item_hovered(item: ShopItem) -> void:
	# TODO: show "- Price" after currency count
	if not item.sold:
		item_hovered.emit(item.species)

func _on_item_exited(item: ShopItem) -> void:
	item_exited.emit()

func _on_item_pressed(item: ShopItem) -> void:
	floating_creature_asked.emit(item) # connected in inspector
	sfx_click.play()

func _on_re_roll_pressed() -> void:
	rerolled.emit() # connected in inspector to world

##called by world
func do_reroll() -> void:
	populate_shop()

func add_shop_item(shop_item: Control) -> void:
	grid_container.add_child(shop_item)

func get_shop_items() -> Array[Node]:
	return grid_container.get_children()

func clear_items() -> void:
	print_debug("clear")
	for item: ShopItem in grid_container.get_children():
		grid_container.remove_child(item)
		item.queue_free()

func create_new_shop_item(id: int) -> void:
	var species: SpeciesResource = Constants.get_species_by_id(id)
	var new_item: Control = ITEM_SCENE.instantiate()
	new_item.species = species
	var base_price: int = 10
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
	new_item.price = int((base_price + base_price * (level / 20.0)) * randf_range(0.85, 1.15))
	add_shop_item(new_item)
	new_item.mouse_entered.connect(_on_item_hovered.bind(new_item))
	new_item.mouse_exited.connect(_on_item_exited.bind(new_item))
	new_item.pressed.connect(_on_item_pressed.bind(new_item))

func populate_creative_shop() -> void:
	print_debug("populate in debug mode")
	for id in Constants.SPECIES.values():
		if stop_at_six and get_shop_items().size() >= 6:
			break
		create_new_shop_item(id)

func populate_shop() -> void:
	clear_items()
	var shop_items: Array[Constants.SPECIES]
	
	if level == 1:
		re_roll.hide()
		shop_items = [Constants.SPECIES.GRASS]
	elif level == 2:
		shop_items = [Constants.SPECIES.BUNNY]
	elif level <= 3:
		re_roll.show()
		shop_items = get_species_by_rarity([Constants.RARITIES.COMMON], 6)
	elif level <= 5:
		shop_items = get_species_by_rarity([Constants.RARITIES.COMMON], 5) + get_species_by_rarity([Constants.RARITIES.UNCOMMON], 1)
	elif level <= 6:
		shop_items = get_species_by_rarity([Constants.RARITIES.COMMON], 4) + get_species_by_rarity([Constants.RARITIES.UNCOMMON], 1) + get_species_by_rarity([Constants.RARITIES.RARE], 1)
	elif level <= 8:
		shop_items = get_species_by_rarity([Constants.RARITIES.COMMON], 3) + get_species_by_rarity([Constants.RARITIES.UNCOMMON], 2) + get_species_by_rarity([Constants.RARITIES.RARE], 1)
	elif level <= 10:
		shop_items = get_species_by_rarity([Constants.RARITIES.COMMON], 2) + get_species_by_rarity([Constants.RARITIES.UNCOMMON], 2) + get_species_by_rarity([Constants.RARITIES.RARE], 2)
	else:
		shop_items = get_species_by_rarity([Constants.RARITIES.COMMON], 2) + get_species_by_rarity([Constants.RARITIES.UNCOMMON], 2) + get_species_by_rarity([Constants.RARITIES.RARE], 2)
	
	shop_items.shuffle()
	for id in shop_items:
		create_new_shop_item(id)


func get_species_by_rarity(rarity: Array[Constants.RARITIES], amount: int = 0) -> Array[Constants.SPECIES]:
	var queried_species: Array[Constants.SPECIES]
	
	for specie: Constants.SPECIES in Constants.SPECIES.size():
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
