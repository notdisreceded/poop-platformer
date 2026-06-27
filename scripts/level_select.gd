extends Node2D
class_name LevelSelect

# This will run when the scene tree has finished loading
@export
var levelTemplateUi : Control

@export
var levels : Array[String]

@export
var gameManager : GameManager

func onButtonPressed (level : String):
	gameManager.switch_scene (level)

func onSceneLoaded () -> void:
	var dataResource: PlayerData = load ("res://resources/player_data.tres")

	for level in dataResource.unlockedLevels:
		levels.append (level)
		print ("Appended ", level)
		
	var index := 0

	levelTemplateUi.visible = false

	for level in levels:
		var clone := levelTemplateUi.duplicate ()

		levelTemplateUi.get_parent ().add_child (clone) # and then i have to add this i hate this fucking gay ass engine
		clone.visible = true

		var label : Label = clone.find_child ("Label", true, false)
		var button : Button = clone.find_child ("Button", true, false)

		print (label)

		if button:
			button.button_down.connect (func (): onButtonPressed (level))

		if label:
			index += 1
			label.text = str (index)

			print ("Set label")
		else:
			push_warning ("Could not find label!")
			continue


func _ready() -> void:
	onSceneLoaded ()
