extends Node2D
class_name GameManager

# fields
@export var voidHeight : float = 0
@export var playerSpawnPoint : Vector2 = Vector2 (0, 0)
@export var destroyVoidedObjects := true
@export var teleportVoidedObjects := false
@export var voidedObjectTeleportPoint : Vector2 = Vector2 (0, 0)
@export var showLoadingScreen := false
@export var generatePlayerCamera := true
@export var generatePlayer := true
@export var remotePath : Node2D
@onready var playerResource := preload ("res://scenes/player.tscn")
@onready var loadingScreenResource := preload ("res://scenes/loading_screen.tscn")
# properties
var player : Player
var switchingScenes = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if showLoadingScreen:
		var loadingScreenScene : CanvasLayer = loadingScreenResource.instantiate ()
		var loadingScreen : TextureRect = loadingScreenScene.find_child ("TextureRect")
		
		get_tree ().root.add_child (loadingScreenScene) 
		
		var tween = create_tween ()
		
		tween.set_ease (Tween.EASE_IN)
		tween.set_trans (Tween.TRANS_QUART)
		tween.tween_property (loadingScreen, "position", Vector2 (1500, 0), 1)
		
		await tween.finished
		loadingScreen.queue_free ()
		print ("Tween done")

	if playerResource.can_instantiate () and generatePlayer:
		player = playerResource.instantiate ()
		
		player.generatePlayerCamera = generatePlayerCamera
		
		if remotePath:
			player.remotePath = remotePath.get_path ()
			
		add_child.call_deferred (player)
		player.position = playerSpawnPoint
		
func wait (time : float):
	var timer := get_tree ().create_timer (time)
	
	await timer.timeout
	timer.free ()
func switch_scene (scene : String):
	if loadingScreenResource.can_instantiate () and not switchingScenes:
		switchingScenes = true

		var loadingScreenScene : CanvasLayer = loadingScreenResource.instantiate ()
		var loadingScreen : TextureRect = loadingScreenScene.find_child ("TextureRect")

		get_tree ().root.add_child (loadingScreenScene) 
		
		print ("Loading screen parent: ", loadingScreen.get_path ())
		
		loadingScreen.position = Vector2 (-1500, 0)
		
		var tween = create_tween ()
		
		tween.set_ease (Tween.EASE_IN)
		tween.set_trans (Tween.TRANS_QUART)
		tween.tween_property (loadingScreen, "position", Vector2 (0, 0), 1)
		
		await tween.finished
		await get_tree().create_timer (1).timeout
		
		loadingScreen.queue_free ()
		get_tree ().change_scene_to_file (scene)
