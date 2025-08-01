class_name Constants

const species_dir: String = "res://resources/species/"

enum SPECIES {
	NONE,
	BUNNY,
	FOX,
	GRASS,
	WORM
}

enum FAMILIES {
	PLANT,
	ANIMAL,
	MUSHROOM,
	OTHER,
}

enum SIZES {
	TINY,
	SMALL,
	MEDIUM,
	LARGE
}

enum RARITIES {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

#func _ready() -> void:
	#all_species = [preload("res://resources/species/bunny.tres"), preload("res://resources/species/fox.tres"), preload("res://resources/species/grass.tres"), preload("res://resources/species/worm.tres")]
	##get_species()
	#print(all_species)

static func get_species_by_id(id: SPECIES) -> SpeciesResource:
	assert(SPECIES.values().has(id), "Unknown species ID")
	return load(species_dir + SPECIES.keys()[id].to_lower() + ".tres")

#func get_species() -> void:
	#var dirc = ResourceLoader.list_directory(species_dir)
	#
	#if dirc:
		#dirc.list_dir_begin()
		#var file_name = dirc.get_next()
		#while file_name != "":
			#if not dirc.current_is_dir():
				#if file_name.get_file().ends_with(".tres"):
					#var file_path = species_dir.path_join(file_name)
					#var resource = ResourceLoader.load(file_path)
					#if resource is SpeciesResource:
						#all_species.append(resource)
			#file_name = dirc.get_next()
	#
	#else:
		#print("An error occurred when trying to access the path.")
