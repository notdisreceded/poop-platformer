extends Button

@onready var scene = "res://scenes/level.tscn"

func onPressed ():
	var gameManager : GameManager = get_node ("/root/GameManager")
	gameManager.switch_scene (scene)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect (onPressed)
