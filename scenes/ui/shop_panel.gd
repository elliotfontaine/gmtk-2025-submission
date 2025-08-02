extends PanelContainer

signal floating_creature_asked(species: SpeciesResource)

# debug for the shop means creative mode: you can add stuff for free
@export var debug: bool = true

@onready var grid_container := %GridContainer
@onready var sfx_click: AudioStreamPlayer = %SFX_Click

const ITEM_SCENE := preload("res://scenes/ui/shop_item.tscn")

func _ready() -> void:
	clear()
	if debug:
		populate_debug_shop()

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

func clear() -> void:
	print_debug("clear")
	for item in grid_container.get_children():
		grid_container.remove_child(item)
		item.queue_free()
	
func populate_debug_shop() -> void:
	print_debug("populate in debug mode")
	#var species: Array[SpeciesResource] = CreatureDataManager.all_species
	for id in Constants.SPECIES.values():
		if id == Constants.SPECIES.NONE:
			continue
		var species: SpeciesResource = Constants.get_species_by_id(id)
		var new_item: Control = ITEM_SCENE.instantiate()
		new_item.species = species
		new_item.price = 0
		add_shop_item(new_item)
		new_item.mouse_entered.connect(_on_item_hovered.bind(new_item))
		new_item.mouse_exited.connect(_on_item_exited.bind(new_item))
		new_item.pressed.connect(_on_item_pressed.bind(new_item))
