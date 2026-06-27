extends Resource
class_name PlayerData

@export var unlockedLevels : Array[String] = []
@export var poopColor : Color = Color ("#5c1d09")

func toDictionary () -> Dictionary:
	var dictionary = {}

	dictionary.unlockedLevels = unlockedLevels
	dictionary.poopColor = poopColor

	return dictionary
