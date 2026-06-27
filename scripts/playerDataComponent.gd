extends Component
class_name PlayerDataComponent

var filePath = "user://savedata.dat"
var levelsPath = "user://unlockedLevels.dat"
var dataResource: PlayerData = preload("res://resources/player_data.tres")

func loadData ():
	if not FileAccess.file_exists(filePath):
		return dataResource

	var file = FileAccess.open(filePath, FileAccess.READ)
	var fileData : Dictionary = file.get_var ()

	file.close ()
	
		
	var data : Dictionary = fileData.duplicate ()

	print ("unlocked levels: ", data["unlockedLevels"])
	dataResource.unlockedLevels = data.unlockedLevels

	for key in data.keys ():
		print ("iterating over ", key)
		var value = data[key]

		print ("DRKE: ", dataResource[key])
		if dataResource[key]:
			dataResource[key] = value
			print ("Set ", key, " to ", value)

	return dataResource


func saveData (data: Dictionary):
	for dataName in data.keys():
		if dataResource[dataName]:
			dataResource[dataName] = data[dataName]

	var file = FileAccess.open(filePath, FileAccess.WRITE)

	file.store_var (dataResource.toDictionary ().duplicate ())
	file.close()

func _ready() -> void:
	print (loadData ().toDictionary ())

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		saveData (dataResource.toDictionary ())
