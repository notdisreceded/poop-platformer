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
@export var showHealthbar := true
@export var showPoopbar := true
@export var remotePath : Node2D
@onready var playerResource := preload ("res://scenes/player.tscn")
@onready var loadingScreenResource := preload ("res://scenes/loading_screen.tscn")

# properties
var player : Player
var switchingScenes = false
var shakeStrength := 0.0

# functions
func shakeCamera (strength : float):
	shakeStrength = strength

func onPlayerDamaged (amount : float, _health : float):
	shakeCamera (amount * 15)

func onPlayerDied ():
	print ("Player has died.")

	var x : Sprite2D = player.find_child ("X")
	var gameOverSound : AudioStreamPlayer = player.find_child ("GameOver")

	gameOverSound.play ()
	var xScale := 0.215

	x.visible = true
	var tween = create_tween ()

	tween.set_ease (Tween.EASE_IN)
	tween.set_trans (Tween.TRANS_EXPO)
	tween.tween_property (x, "self_modulate", Color ("ff0000"), 0.675)
	tween.tween_property (x, "scale", Vector2 (xScale, xScale), 0.45)

	await tween.finished

	shakeCamera (26)

	player.setKnockbackForce (Vector2 (0, -250), 0.7)
	player.find_child ("Collision").queue_free ()
	player.find_child ("VoidBehavior").queue_free ()

	await get_tree().create_timer (1).timeout

	switch_scene (get_tree ().current_scene.scene_file_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if showLoadingScreen:
		var loadingScreenScene : CanvasLayer = loadingScreenResource.instantiate ()
		var loadingScreen : TextureRect = loadingScreenScene.find_child ("TextureRect")
		
		get_tree ().root.add_child (loadingScreenScene) 
		
		var tween = create_tween ()
		loadingScreenScene.find_child ("Slide").play ()
		
		tween.set_ease (Tween.EASE_IN)
		tween.set_trans (Tween.TRANS_QUART)
		tween.tween_property (loadingScreen, "position", Vector2 (1500, 0), 1)
		
		await tween.finished
		loadingScreen.queue_free ()
		print ("Tween done")

	if playerResource.can_instantiate () and generatePlayer:
		player = playerResource.instantiate ()
		
		player.generatePlayerCamera = generatePlayerCamera
		player.showHealthbar = showHealthbar
		player.showPoopbar = showPoopbar
		player.died.connect (onPlayerDied)
		
		if remotePath:
			player.remotePath = remotePath.get_path ()
			
		add_child.call_deferred (player)
		player.position = playerSpawnPoint

		player.damaged.connect (onPlayerDamaged)

		
		
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

		loadingScreenScene.find_child ("Slide").play ()
		
		await tween.finished
		await get_tree().create_timer (1).timeout
		
		loadingScreen.queue_free ()
		get_tree ().change_scene_to_file (scene)


func _process (delta: float) -> void:
	if shakeStrength > 0:
		shakeStrength = lerpf (shakeStrength, 0.0, 10.0 * delta)

		var camera := get_viewport ().get_camera_2d ()

		if camera:
			camera.offset = Vector2 (randf_range (-shakeStrength, shakeStrength), randf_range (-shakeStrength, shakeStrength))
