extends Node2D
class_name TeleportObject

# variables
@export var point : Vector2

# functions
func teleport (object : Node2D):
	object.global_position = point
