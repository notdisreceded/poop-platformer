extends CharacterBody2D
class_name Player

# variables
@export var speed : float
@export var jumpVelocity : float
@export var minGravity : float
@export var maxGravity : float
@export var gravityAcceleration : float
@export var acceleration : float
@export var deceleration : float
@export var poopFallRate : float = 1000
@export var generatePlayerCamera := true
@export var showHealthbar := true
@export var showPoopbar := true
@export var remotePath : NodePath
@export var poopUsageRate := 28
@export var poopRegenRate := 12.5

@export var health : float = 3:
	set (value):
		if value > maxHealth:
			print ("Clamped health to max")
			health = maxHealth

		elif value <= 0:
			health = 0
			died.emit ()

		else:
			health = value

# properties
@onready
var playerDataComponent : PlayerDataComponent = $PlayerDataComponent 
var healthBarResource = preload ("res://scenes/healthbar.tscn")
var poopBarResource = preload ("res://scenes/poopMeter.tscn")
var horizontalDirection := 0.0
var damageImmunityTimer : float = 0
var noPoopRegenTimer : float = 0
var kbForce := Vector2 (0, 0)
var gravity := minGravity
var healthFill : ColorRect
var poopFill : ColorRect
var maxHealth := health
var lastDiTick : float = 0
var now = 0
var canJump := true
var normalPoopFillColor : Color
var emergencyPoopFillColor := Color ("ff5340")

var dead : bool = false:
	get: # returns a boolean if we're dead
		return health <= 0
	set (value): # if this variable is set to true the player dies, if the player is already dead and we try to set it to something else it will remain true
		if value == true:
			health = 0
			dead = true
		
		if health <= 0:
			dead = true

var maxPoopMeter := 100.0

var poop := maxPoopMeter: # properties automatically clamps this value between 0 and maxPoopMeter
	set (value):
		if value > maxPoopMeter:
			poop = maxPoopMeter
		elif value < 0:
			poop = 0
		else:
			poop = value

var isHoldingJump := false:
	set (value):
		
		if value == true and isHoldingJump != true:
			print ("Started jumping event fired")
			startedJumping.emit ()
		elif value == false and isHoldingJump != false:
			print ("Stopped jumping event fired")
			stoppedJumping.emit ()

		isHoldingJump = value

# signals/events
signal damaged (amount, health)
signal died
signal ranOutOfShit
signal startedJumping
signal stoppedJumping

func setKnockbackForce (kb : Vector2, time : float):
	kbForce = kb
	await get_tree ().create_timer (time).timeout
	kbForce = Vector2 (0, 0)

func canDamage () -> bool:
	return damageImmunityTimer <= 0

func damage (amount : float, immunity : float):
	if damageImmunityTimer > 0:
		return

	health = health - amount
	
	if health >= 0:
		damageImmunityTimer = immunity
	
	damaged.emit (amount, health)

	print ("Did ", amount, " damage to player.")
	print ("New health: ", health)

	$Damaged.play ()
	
func onStoppedJumping ():
	# delay poop regeneration based on how full your poop meter is

	print ("Stopped jumping")
	noPoopRegenTimer += 0.5 * (1 - poop / maxPoopMeter)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	if not generatePlayerCamera:
		$Camera2D.queue_free ()

	print (healthBarResource.can_instantiate ())

	if healthBarResource.can_instantiate () and showHealthbar:
		var healthBar := healthBarResource.instantiate ()

		get_tree ().root.add_child (healthBar)
		healthFill = healthBar.find_child ("TextureRect").find_child ("ColorRect")
		
	if poopBarResource.can_instantiate () and showPoopbar:
		var poopBar := poopBarResource.instantiate ()

		get_tree ().root.add_child (poopBar)
		poopFill = poopBar.find_child ("Background").find_child ("Fill")
		normalPoopFillColor = poopFill.color
		

	

	ranOutOfShit.connect (onRanOutOfShit)
	stoppedJumping.connect (onStoppedJumping)

func onJump ():
	if canJump:
		$Noise.play ()
		$Noise2.play ()

	

func onJumpReleased ():
	noPoopRegenTimer += 4

func onRanOutOfShit ():
	noPoopRegenTimer = 8


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process (_delta : float):
	now += _delta

	# Handle ui stuff
	if healthFill:
		healthFill.size.x = 14.73 * (health / maxHealth)

	var poopFillSize := 431 * (poop / maxPoopMeter)

	# append .0 to suppress the divison warning
	var hopThreshold := 15.0 / 100.0 * maxPoopMeter

	if poopFill:
		poopFill.size.x = poopFillSize

		if poop <= hopThreshold:
			poopFill.color = emergencyPoopFillColor
		else:
			poopFill.color = normalPoopFillColor	

	if dead:
		return

	horizontalDirection = Input.get_axis ("left", "right")
	isHoldingJump = Input.is_action_pressed ("jump") and canJump
	
	if Input.is_action_just_pressed ("jump"):
		onJump ()

	var targetVelocity = Vector2 (horizontalDirection * speed, 0)
	var xVelocity = targetVelocity.x
	var yVelocity = targetVelocity.y
	
	var raycast2d : RayCast2D = $RayCast2D
	var line2d := $PoopLine
	var poopRay := $PoopRay
	var poopSplatter := $PoopSplatter
	var poopParticles := $PoopParticles

	# Handle timer variables
	damageImmunityTimer = clamp (damageImmunityTimer - _delta, 0, 100000)
	noPoopRegenTimer = clamp (noPoopRegenTimer - _delta, 0, 100000)
		
	# If we are accelerating then
	if velocity.x < targetVelocity.x:
		xVelocity = minf (velocity.x + acceleration * _delta, speed)
	# If we are decelerating then
	elif velocity.x > targetVelocity.x:
		xVelocity = maxf (velocity.x - deceleration * _delta, -speed)

	# Handle jumping
	if noPoopRegenTimer <= 0:
		poop += poopRegenRate * _delta

	print (canJump)

	# Do a short little hop
	if Input.is_action_just_pressed ("jump") and is_on_floor () and poop <= hopThreshold and poop > 0:
		noPoopRegenTimer += .75

		poopParticles.emitting = true
		poopParticles.emitting = false
		
		poop -= 1.5
		velocity.y -= jumpVelocity * 1.9
		$TinyHop.play ()

	canJump = poop >= hopThreshold

	print ("Poop: ", poop)


	if isHoldingJump and canJump:
		var multBy := clampf ((poop  + 25) / maxPoopMeter, 0, 1)

		print ("Mult by: ", multBy)

		targetVelocity.y -= jumpVelocity * multBy
		raycast2d.target_position.y += poopFallRate *  _delta

		poop -= poopUsageRate * _delta
		gravity = max (gravity - gravityAcceleration * _delta, minGravity)

		if poop <= 0:
			noPoopRegenTimer = 6
			ranOutOfShit.emit ()
	
	else:
		$Noise2.stop ()
		raycast2d.target_position.y = 0
		
		gravity = min (gravity + gravityAcceleration * _delta, maxGravity)
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
	velocity = Vector2 (xVelocity, yVelocity) + kbForce

	# -- visuals --

	poopRay.emitting = isHoldingJump and canJump
	line2d.visible = isHoldingJump and canJump
	line2d.points[1].y = raycast2d.target_position.y + 150
	poopSplatter.emitting = raycast2d.is_colliding () and isHoldingJump and canJump

	poopSplatter.color = playerDataComponent.dataResource.poopColor
	line2d.default_color = playerDataComponent.dataResource.poopColor
	poopRay.color = playerDataComponent.dataResource.poopColor

	if raycast2d.is_colliding () and isHoldingJump and canJump:
		var point = raycast2d.get_collision_point ()

		poopSplatter.global_position = point

	# Remote transform
	$RemoteTransform.remote_path = remotePath
	$RemoteTransform.update_rotation = false
	$RemoteTransform.update_position = true


	if damageImmunityTimer > 0:
		print (damageImmunityTimer)

		if (now - lastDiTick) < damageImmunityTimer / 2:
			visible = false
		else:
			lastDiTick = now
			visible = true
	elif damageImmunityTimer <= 0 and not visible:
		visible = true

	move_and_slide ()
	
