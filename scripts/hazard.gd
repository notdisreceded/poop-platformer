extends Area2D
class_name Hazard

# signal
signal hitPlayer

# properties
@export var damage : float
@export var damageImmunityTime : float
@export var knockback : float = 100

# logic
func onBodyEntered (body : PhysicsBody2D):
    if body is Player:
        var pos := global_position
        var playerPos := body.global_position
        var kbDirection := -((pos - playerPos) * 5) + Vector2 (0, -1) * knockback

        body.setKnockbackForce (kbDirection, 0.01)
        hitPlayer.emit ()
        body.damage (damage, damageImmunityTime)

func _ready() -> void:
    body_entered.connect (onBodyEntered)