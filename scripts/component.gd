class_name Component
extends Node

# initialize siblingComponents
var siblingComponents : Dictionary[String, Component] = {}

func _ready() -> void:
	var siblings = get_parent ().get_children ()

	for sibling in siblings:
		if sibling == self:
			continue
		
		if not sibling is Component:
			continue
		
		siblingComponents[sibling.name] = sibling
