extends Node

const ACCESSED_PATH: String = "res://resources/ingredients/"
var all_ingredients: Array[Ingredient]

func _ready() -> void:
	var dir = DirAccess.open(ACCESSED_PATH)
	if dir:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".remap"):
					file_name = file_name.trim_suffix(".remap")
				if file_name.ends_with(".tres"):
					var resource = load(ACCESSED_PATH + file_name)
					if resource and not all_ingredients.has(resource):
						all_ingredients.append(resource)
						
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("error accessing: ", ACCESSED_PATH)
