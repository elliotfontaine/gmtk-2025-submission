@tool
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
	WOLF,
	TIGER,
	BADGER,
	BUSH,
	BERRY,
	ANT,
	#MOLE,
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
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

static var family_strings: Dictionary = {
	FAMILIES.PLANT: &"plant",
	FAMILIES.ANIMAL: &"animal",
	FAMILIES.MUSHROOM: &"mushroom",
	FAMILIES.OTHER: &"other",
}

static var size_strings: Dictionary = {
	SIZES.TINY: &"tiny",
	SIZES.SMALL: &"small",
	SIZES.MEDIUM: &"medium",
	SIZES.LARGE: &"large",
}

static func get_species_by_id(id: SPECIES) -> SpeciesResource:
	assert(SPECIES.values().has(id), "Unknown species ID")
	return load(species_dir + SPECIES.keys()[id].to_lower() + ".tres")
