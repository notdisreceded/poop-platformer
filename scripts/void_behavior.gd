extends Node2D
class_name VoidBehavior

signal onHitVoid
var gameManager : GameManager

func onVoided ():
	print ("Voided")
	if gameManager.destroyVoidedObjects == true:
		queue_free ()
		return
	if gameManager.teleportVoidedObjects == true:
		self.get_parent ().global_position = gameManager.voidedObjectTeleportPoint
		print ("Teleported")
func _ready ():
	gameManager = get_node ("/root/GameManager")
	
	onHitVoid.connect (onVoided)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_delta: float) -> void:
	if not gameManager:
		push_warning ("Game manager is null.")
		gameManager = get_node ("/root/GameManager")
		return
		
	if self.global_position.y > gameManager.voidHeight:
		onHitVoid.emit ()
		
