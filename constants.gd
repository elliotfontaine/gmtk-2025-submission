class_name Constants

const species_dir: String = "res://resources/species/"

enum SPECIES {
	NONE,
	BUNNY,
	FOX,
	GRASS,
	WORM,
	HEDGEHOG,
	CROW,
	EGG,
	SONGBIRD,
	CHICKEN,
	LYNX,
	#MOLE,
	#SQUIRREL,
	#ROOSTER,
	#OWL,
	#BADGER,
	#WOLF,
	#TIGER,
	#BEAR,
	#ORANGUTAN,
	#BUTTERFLY,
	#BAT,
	#FLOWER,
	#LADYBUG,
	#BEE,
	#HONEY,
	#ANT,
	#SNAKE,
	#VULTURE,
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

static func get_species_by_id(id: SPECIES) -> SpeciesResource:
	assert(SPECIES.values().has(id), "Unknown species ID")
	return load(species_dir + SPECIES.keys()[id].to_lower() + ".tres")
