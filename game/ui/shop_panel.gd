extends PanelContainer

# debug for the shop means creative mode: you can add stuff for free
@export var debug: bool = true

var item_scene := preload("res://game/ui/shop_item.tscn")

@onready var grid_container := %GridContainer

func _ready() -> void:
	clear()
	if debug:
		populate_debug_shop()

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
	for specie in species:
		var new_item := item_scene.instantiate()
		new_item.sprite = specie.texture
		new_item.price = 0
		add_shop_item(new_item)
		
