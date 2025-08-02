extends PanelContainer

signal floating_creature_asked(species: SpeciesResource)

## Creative for the shop means you can add any registered creature for free
@export var creative: bool = false
## Should the creature count stop at the 6 first instead of all registered
@export var stop_at_six: bool = false

@onready var grid_container := %GridContainer
@onready var sfx_click: AudioStreamPlayer = %SFX_Click

const ITEM_SCENE := preload("res://scenes/ui/shop_item.tscn")


func _ready() -> void:
	if creative:
		clear_items()
		populate_creative_shop()
	else:
		clear_items()
		populate_shop()
		# TODO: iDK, I guess maybe it should me managed by the World Scene, since
		# it's gonna fill it mutiple times.

func _on_item_hovered(item) -> void:
	# TODO: show "- Price" after currency count
	# set CreatureCard
	pass

func _on_item_exited(item) -> void:
	# TODO: unshow "- Price"
	pass
	
func _on_item_pressed(item) -> void:
	floating_creature_asked.emit(item.species)
	sfx_click.play() 

func _on_re_roll_pressed() -> void:
	clear_items()
	populate_shop()

func add_shop_item(shop_item: Control) -> void:
	grid_container.add_child(shop_item)

func get_shop_items() -> Array[Node]:
	return grid_container.get_children()

func clear_items() -> void:
	print_debug("clear")
	for item in grid_container.get_children():
		grid_container.remove_child(item)
		item.queue_free()

func create_new_shop_item(id:int) -> void:
	var species: SpeciesResource = Constants.get_species_by_id(id)
	var new_item: Control = ITEM_SCENE.instantiate()
	new_item.species = species
	new_item.price = randi_range(10,999)
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
	var new_items :Array[Constants.SPECIES]
	for i in 6:
		var randnb :int = randi() % Constants.SPECIES.size()
		while Constants.get_species_by_id(randnb).rarity == Constants.RARITIES.NONE:
			randnb = randi() % Constants.SPECIES.size()
			print("rolled a not-available creature, rerolling")
		new_items.append(randnb)
	for id in new_items:
		create_new_shop_item(id)
