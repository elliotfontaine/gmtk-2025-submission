extends Node

const species_data_folder :String = "res://species_info/"

var all_species :Array[SpeciesData]

func _ready() -> void:
	all_species = [preload("res://species_info/bunny.tres"), preload("res://species_info/fox.tres"), preload("res://species_info/grass.tres"), preload("res://species_info/worm.tres")]
	#get_species()
	print(all_species)

func get_species() -> void:
	var dirc = ResourceLoader.list_directory(species_data_folder)
	
	if dirc:
		dirc.list_dir_begin()
		var file_name = dirc.get_next()
		while file_name != "":
			if not dirc.current_is_dir():
				if file_name.get_file().ends_with(".tres"):
					var file_path = species_data_folder.path_join(file_name)
					var resource = ResourceLoader.load(file_path)
					if resource is SpeciesData:
						all_species.append(resource)
			file_name = dirc.get_next()
	
	else:
		print("An error occurred when trying to access the path.")
