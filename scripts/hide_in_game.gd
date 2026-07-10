extends Node
class_name HideInGame


func _ready() -> void:
    get_parent ().queue_free ()