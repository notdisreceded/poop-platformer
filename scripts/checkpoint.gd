extends Node2D
class_name Checkpoint

# properties
# @export var nextLevelPath : String

@export var litColor := Color ("#ffa300")
@export var litTweenLength : float = 1

# nodes
@export var area2D :Area2D

# variables
var touched := false

# functions
func onPlayerEntered (player : Player):
    print ("Player entered")
    
    # Old code

    # var playerData := player.playerDataComponent.dataResource
    # var playerDataComponent := player.playerDataComponent

    # if not playerData.unlockedLevels.has (nextLevelPath):
    #     playerData.unlockedLevels.append (nextLevelPath)
    #     playerDataComponent.saveData (playerData.toDictionary ())

    #     print (playerData.unlockedLevels)

    if touched:
        return

    touched = true

    player.checkpointPosition = global_position
    player.health = player.maxHealth
    player.poop = player.maxPoopMeter

    var tween := create_tween ()

    tween.set_trans (Tween.TRANS_CIRC)
    tween.set_ease (Tween.EASE_OUT)
    tween.tween_property ($Sprite, "modulate", litColor, litTweenLength)


func onBodyEntered (body : PhysicsBody2D):
    if body is Player:
        onPlayerEntered (body)
    
    

func _ready():
    area2D.body_entered.connect (onBodyEntered)