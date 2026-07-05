extends Node2D
class_name FinishPoint

# properties
@export var nextLevelPath : String

# functions
func moveToNextStage (body : PhysicsBody2D):
	print ("Called ", body.name)
	var gameManager : GameManager = $"/root/GameManager"

	if not gameManager:
		return

	var player : Player = gameManager.player

	if not player:
		return

	# add level to the level select
	var playerData := player.playerDataComponent.dataResource
	var playerDataComponent := player.playerDataComponent

	playerData.unlockedLevels.append (nextLevelPath)
	playerDataComponent.saveData (playerData.toDictionary ())

	if not playerData.unlockedLevels.has (nextLevelPath):
		playerData.unlockedLevels.append (nextLevelPath)
		playerDataComponent.saveData (playerData.toDictionary ())

	print (playerData.unlockedLevels)

	# switch to next stage
	gameManager.switch_scene (nextLevelPath)
