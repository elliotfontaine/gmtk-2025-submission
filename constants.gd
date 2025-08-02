class_name Constants

const species_dir: String = "res://resources/species/"

enum SPECIES {
	#NONE, why is there none? this fucks up crawling through so the enum
	MOLE,
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
	WOLF,
	TIGER,
	BADGER,
	BUSH,
	BERRY,
	ANT,
	#SQUIRREL,
	#ROOSTER,
	#OWL,
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
	NONE,
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

static func get_species_by_id(id: SPECIES) -> SpeciesResource:
	assert(SPECIES.values().has(id), "Unknown species ID")
	return load(species_dir + SPECIES.keys()[id].to_lower() + ".tres")
