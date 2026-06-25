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

var isHoldingJump := false
var horizontalDirection := 0
var health = 100

func damage (amount : float):
	health -= amount
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not generatePlayerCamera:
		$Camera2D.queue_free ()
		
	

func onJump ():
	$Noise.play ()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process (_delta : float):
	horizontalDirection = Input.get_axis ("left", "right")
	isHoldingJump = Input.is_action_pressed ("jump")
	
	if Input.is_action_just_pressed ("jump"):
		onJump ()

	var targetVelocity = Vector2 (horizontalDirection * speed, 0)
	var xVelocity = targetVelocity.x
	var yVelocity = targetVelocity.y
	
	var line2d := $PoopLine
	var raycast2d : RayCast2D = $RayCast2D
	var poopRay := $PoopRay
	var poopSplatter = $PoopSplatter
		
	# If we are accelerating then
	if velocity.x < targetVelocity.x:
		xVelocity = minf (velocity.x + acceleration, speed)
	# If we are decelerating then
	elif velocity.x > targetVelocity.x:
		xVelocity = maxf (velocity.x - deceleration, -speed)
	
	var collisionPoint = Vector2.ZERO
	print ("IS collidng: ", raycast2d.is_colliding ())
	
	line2d.points[1] = raycast2d.target_position

	if raycast2d.is_colliding () == false:
		collisionPoint.x = global_position.x
		collisionPoint.y = raycast2d.target_position.y
		
	
		
		
	else:
		collisionPoint = raycast2d.get_collision_point ()

		
	if isHoldingJump:
		targetVelocity.y = -jumpVelocity

		print (collisionPoint.y)

		raycast2d.target_position += Vector2 (0, poopFallRate * _delta)

		line2d.points[1] = to_local (Vector2 (collisionPoint.x, collisionPoint.y + 10))
		poopRay.gravity = Vector2 (0, 5  * line2d.get_point_position (1).y)
	else:
		targetVelocity.y += gravity
		
		raycast2d.target_position.y = 0
		
		line2d.points[1] = to_local (Vector2.ZERO)
		poopRay.gravity = Vector2 (0, 0)

		collisionPoint = Vector2.ZERO
		
	yVelocity = lerp (velocity.y, targetVelocity.y, .8 * _delta)
		
	velocity = Vector2 (xVelocity, yVelocity)
	
	# -- visuals --

	poopRay.emitting = isHoldingJump
	line2d.visible = isHoldingJump
	
	poopSplatter.emitting = raycast2d.is_colliding () and isHoldingJump
	if raycast2d.is_colliding () and isHoldingJump:
		var point = raycast2d.get_collision_point ()

		poopSplatter.global_position = point
	move_and_slide ()
	
