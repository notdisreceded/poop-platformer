extends Area2D
class_name Hazard

# signal
signal hitPlayer

# properties
@export var damage : float
@export var damageImmunityTime : float
@export var knockback : float = 100

# if true, the damage this hazard does scales on the hazards size
@export var damageScalingEnabled := true 
@export var colorGradient : Gradient

# logic
func calculateDamage () -> float:
	if not damageScalingEnabled:
		return damage

	var size := global_scale
	print ("Hazard global scale: ", size)

	var damageDealt := damage
		
	if damageScalingEnabled:
		damageDealt *= size.y / 2.273

		print ("Damage dealt: ", damageDealt)

	return damageDealt

func onBodyEntered (body : PhysicsBody2D):
	if body is Player:
		var pos := global_position
		var playerPos := body.global_position
		var kbDirection := -((pos - playerPos) * 5) + Vector2 (0, -1) * knockback * calculateDamage()

		body.setKnockbackForce (kbDirection, 0.01)
		hitPlayer.emit ()
		body.damage (calculateDamage(), damageImmunityTime)

func _ready() -> void:
	body_entered.connect (onBodyEntered)

	var sprite : Sprite2D = $"../Sprite"

	if sprite and colorGradient:
		sprite.self_modulate = colorGradient.sample (calculateDamage ())
		print ("Set color")
