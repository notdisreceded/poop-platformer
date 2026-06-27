extends CharacterBody2D
class_name Player

# variables
@export var speed : float
@export var jumpVelocity : float
@export var gravity : float
@export var acceleration : float
@export var deceleration : float
@export var poopFallRate : float = 1000
@export var generatePlayerCamera := true


@onready
var playerDataComponent : PlayerDataComponent = $PlayerDataComponent 

var isHoldingJump := false
var horizontalDirection := 0.0
var health = 100



func damage (amount : float):
	health -= amount
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not generatePlayerCamera:
		$Camera2D.queue_free ()
		
	

func onJump ():
	$Noise.play ()
	$Noise2.play ()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process (_delta : float):
	horizontalDirection = Input.get_axis ("left", "right")
	isHoldingJump = Input.is_action_pressed ("jump")
	
	if Input.is_action_just_pressed ("jump"):
		onJump ()

	var targetVelocity = Vector2 (horizontalDirection * speed, 0)
	var xVelocity = targetVelocity.x
	var yVelocity = targetVelocity.y
	
	var raycast2d : RayCast2D = $RayCast2D
	var line2d := $PoopLine
	var poopRay := $PoopRay
	var poopSplatter = $PoopSplatter
		
	# If we are accelerating then
	if velocity.x < targetVelocity.x:
		xVelocity = minf (velocity.x + acceleration, speed)
	# If we are decelerating then
	elif velocity.x > targetVelocity.x:
		xVelocity = maxf (velocity.x - deceleration, -speed)

	if isHoldingJump:
		targetVelocity.y -= jumpVelocity
		raycast2d.target_position.y += poopFallRate *  _delta
	else:
		$Noise2.stop ()
		raycast2d.target_position.y = 0
		
		targetVelocity.y += gravity
	var isRaycastColliding := raycast2d.is_colliding ()
	# print ("IS collidng: ", isRaycastColliding)

	if isRaycastColliding:
		raycast2d.target_position.y = raycast2d.to_local (raycast2d.get_collision_point ()).y
	else:
		# positive y is down and negative y is up

		raycast2d.target_position.y += poopFallRate * _delta

	# Jump
	yVelocity = lerp (velocity.y, targetVelocity.y, .8 * _delta)
	velocity = Vector2 (xVelocity, yVelocity)
	
	# -- visuals --

	poopRay.emitting = isHoldingJump
	line2d.visible = isHoldingJump
	line2d.points[1].y = raycast2d.target_position.y + 150

	# print ("Y: ", line2d.points[1].y)
	# print ("RAYCAST Y: ", raycast2d.target_position.y)

	poopSplatter.emitting = raycast2d.is_colliding () and isHoldingJump
	poopSplatter.color = playerDataComponent.dataResource.poopColor
	line2d.default_color = playerDataComponent.dataResource.poopColor
	poopRay.color = playerDataComponent.dataResource.poopColor

	if raycast2d.is_colliding () and isHoldingJump:
		var point = raycast2d.get_collision_point ()

		poopSplatter.global_position = point

	move_and_slide ()
	
