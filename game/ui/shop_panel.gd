extends PanelContainer

signal floating_creature_asked(species: SpeciesData)

# debug for the shop means creative mode: you can add stuff for free
@export var debug: bool = true

@onready var grid_container := %GridContainer

const ITEM_SCENE := preload("res://game/ui/shop_item.tscn")

func _ready() -> void:
	clear()
	if debug:
		populate_debug_shop()

func _on_item_hovered(item) -> void:
	print(str(item.species.id) + " hovered !")
	# show "- Price" after currency count
	# set CreatureCard

func _on_item_exited(item) -> void:
	# unshow "- Price"
	pass
	
func _on_item_pressed(item) -> void:
	floating_creature_asked.emit(item.species)

func add_shop_item(shop_item: Control) -> void:
	grid_container.add_child(shop_item)

func clear() -> void:
	print_debug("clear")
	for item in grid_container.get_children():
		grid_container.remove_child(item)
		item.queue_free()
	
func populate_debug_shop() -> void:
	print_debug("populate in debug mode")
	var species: Array[SpeciesData] = CreatureDataManager.all_species
	for sp in species:
		var new_item: Control = ITEM_SCENE.instantiate()
		new_item.species = sp
		new_item.sprite = sp.texture
		new_item.price = 0
		add_shop_item(new_item)
		new_item.mouse_entered.connect(_on_item_hovered.bind(new_item))
		new_item.mouse_exited.connect(_on_item_exited.bind(new_item))
		new_item.pressed.connect(_on_item_pressed.bind(new_item))
		
