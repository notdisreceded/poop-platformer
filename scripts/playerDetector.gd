extends Area2D
class_name PlayerDetector

# signals
signal touchedPlayer (player : Player)

# properties
@export var cooldown := 0.0

var lastHit := -100.0
var now := 0.0

# functions
func onTouchedPlayer (_player : Player):
    pass

func onTouchedObject (body : PhysicsBody2D):

    if body is Player and now - lastHit >= cooldown:
        lastHit = now

        print ("Event fired")
        
        touchedPlayer.emit (body)
        onTouchedPlayer (body)

func _ready() -> void:
    body_entered.connect (onTouchedObject)

func _process (delta: float) -> void:
    now += delta