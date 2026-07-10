@tool

extends Node2D
class_name TeleportObject

# properties
@export var point : Vector2
@export var velocity : Vector2 = Vector2 (0, 0)
@export var relativeVelocity : bool = true
@export var velocityLength := 0.1
@export var targetNode : Node2D
@export var disabled := false:
	set (value):

		# makes the code redundant,
		# all this does is make the vfx invisible if disabled is true and vice versa
		# var glow := get_node_or_null ("Glow")

		# if glow:
		# 	glow.visible = not value

		# var particles := get_node_or_null ("Particles")

		# if particles:
		# 	particles.visible = not value

		# fire events
		if value == true:
			onDisabled.emit ()
				
		else:
			onEnabled.emit ()

		disabled = value

# variables
var lastPipe : TeleportObject

signal touchedPlayer (player : Player)
signal playerLeft (player : Player)

# signals
signal onDisabled
signal onEnabled

# functions
func teleport (object : Node2D):
	print (name, " disabled: ", disabled)
	if disabled:
		return

	# we tp to the target node
	# last pipe is the previous pipe we used

	var isPlayer := object is Player

	if targetNode:
		point = targetNode.global_position

	if isPlayer:

		if not object.canBeTeleported:
			return

		# add force
		var force = velocity

		if relativeVelocity:
			force = force.rotated (self.rotation)

		if targetNode:
			object.canBeTeleported = false
		
		object.setKnockbackForce (force, velocityLength)
		

		# prevent an infinite loop of pipes
		if targetNode:
			
			
			var parent = targetNode.get_parent ()

			if parent is TeleportObject:
				parent.disabled = true

				print ("awaiting")

				object.global_position = point 
				await get_tree().create_timer(.3).timeout
				
				object.canBeTeleported = true
				parent.disabled = false
			else:
				object.global_position = point 
		else:
			object.global_position = point 
	else:
		object.global_position = point
		

func _draw () -> void:
	if Engine.is_editor_hint ():
		draw_line (global_position, point, Color.RED, -3)

	# draw_line (global_position, point, Color.RED, -3)
	pass
