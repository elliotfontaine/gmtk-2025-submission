extends PanelContainer

signal floating_creature_asked(species: SpeciesResource)

## Creative for the shop means you can add any registered creature for free
@export var creative: bool = true
## Should the creature count stop at the 6 first instead of all registered
@export var stop_at_six: bool = false

@onready var grid_container := %GridContainer
@onready var sfx_click: AudioStreamPlayer = %SFX_Click

const ITEM_SCENE := preload("res://scenes/ui/shop_item.tscn")

func _ready() -> void:
	clear_items()
	#if creative:
		#populate_creative_shop()
	for id in [Constants.SPECIES.BUNNY,Constants.SPECIES.ANT,Constants.SPECIES.GRASS,Constants.SPECIES.ANT,Constants.SPECIES.BUNNY,Constants.SPECIES.GRASS]:
		create_new_shop_item(id)

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

func add_shop_item(shop_item: Control) -> void:
	grid_container.add_child(shop_item)

func get_shop_items() -> Array[Node]:
	return grid_container.get_children()

func clear_items() -> void:
	print_debug("clear")
	for item in grid_container.get_children():
		grid_container.remove_child(item)
		item.queue_free()
	
func populate_creative_shop() -> void:
	print_debug("populate in debug mode")
	for id in Constants.SPECIES.values():
		if stop_at_six and get_shop_items().size() >= 6:
			break
		if id == Constants.SPECIES.NONE:
			continue
		create_new_shop_item(id)

func create_new_shop_item(id:int) -> void:
	var species: SpeciesResource = Constants.get_species_by_id(id)
	var new_item: Control = ITEM_SCENE.instantiate()
	new_item.species = species
	new_item.price = randi_range(10,999)
	add_shop_item(new_item)
	new_item.mouse_entered.connect(_on_item_hovered.bind(new_item))
	new_item.mouse_exited.connect(_on_item_exited.bind(new_item))
	new_item.pressed.connect(_on_item_pressed.bind(new_item))
