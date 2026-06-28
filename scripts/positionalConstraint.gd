extends Node2D
class_name PositionalConstraint

# PositionalConstraints can limit node transform

# Properties
@export var maxY : float
@export var minY: float
@export var minX : float
@export var maxX : float

func _ready() -> void:
    var parent = get_parent () as Node2D

    if not parent is Node2D:
        return

    parent.global_position.x = clamp (global_position.x, minX, maxX)
    parent.global_position.y = clamp (global_position.y, minY, maxY)