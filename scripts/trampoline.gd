extends PlayerDetector
class_name Trampoline


# properties
@export var power := 300
@export var dampeningEnabled := true

var lastHitPlayer := 0.0


func onTouchedPlayer (player : Player):

    var sprite : AnimatedSprite2D = get_node_or_null ("../Sprite")

    if sprite:
        sprite.play ("bounce")

    var direction :=  Vector2 (0, 1).rotated (global_rotation)

    print ("Last hit: ", lastHitPlayer)

    var multiplier = clampf (self.now - self.lastHitPlayer, 0, 1)
    print ("Multiplier: ", multiplier)

    if not dampeningEnabled:
        multiplier = 1

    lastHitPlayer = now

    var scaleMult = global_scale.x / 0.5
    var force : Vector2 = -(direction * power * multiplier * scaleMult)

    player.velocity.y = 0
    player.setKnockbackForce (force, 0.1)

    print ("Bounce power: ", force)

func _ready() -> void:
    super ()

    cooldown = 0
