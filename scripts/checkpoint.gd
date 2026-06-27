extends Node2D
class_name Checkpoint

# properties
@export var nextLevelPath : String

# nodes
@export var area2D :Area2D

# functions
func onPlayerEntered (player : Player):
    print ("Player entered")

    var playerData := player.playerDataComponent.dataResource
    var playerDataComponent := player.playerDataComponent

    playerData.unlockedLevels.append (nextLevelPath)
    playerDataComponent.saveData (playerData.toDictionary ())

    print (playerData.unlockedLevels)



func onBodyEntered (body : PhysicsBody2D):
    if body is Player:
        onPlayerEntered (body)
    
    

func _ready():
    area2D.body_entered.connect (onBodyEntered)