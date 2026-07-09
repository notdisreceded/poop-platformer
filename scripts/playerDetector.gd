extends Area2D
class_name PlayerDetector

# signals
signal touchedPlayer (player : Player)
signal playerLeft (player : Player)

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
        
        touchedPlayer.emit (body)
        onTouchedPlayer (body)

func onObjectLeft (body : PhysicsBody2D):
    print ("something left")

    if body is Player:

        print ("player left")
        playerLeft.emit (body) 

func _ready() -> void:
    body_entered.connect (onTouchedObject)
    body_exited.connect (onObjectLeft)

func _process (delta: float) -> void:
    now += delta