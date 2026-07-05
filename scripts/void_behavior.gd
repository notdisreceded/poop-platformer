extends Node2D
class_name VoidBehavior


# fields

signal onHitVoid

var selfTeleportPoint : Vector2
var gameManager : GameManager

func onVoided ():

	print ("Voided")

	if gameManager.destroyVoidedObjects == true:
		queue_free ()
		return

	if gameManager.teleportVoidedObjects == true:
		self.get_parent ().global_position = selfTeleportPoint
		
		if self.get_parent () is Player:
			self.get_parent ().damage (1, 0)

func _ready ():
	gameManager = get_node ("/root/GameManager")
	selfTeleportPoint = gameManager.voidedObjectTeleportPoint
	onHitVoid.connect (onVoided)


func _process (_delta: float) -> void:
	if not gameManager:
		push_warning ("Game manager is null.")
		gameManager = get_node ("/root/GameManager")
		return
		
	if self.global_position.y > gameManager.voidHeight:
		onHitVoid.emit ()
		
