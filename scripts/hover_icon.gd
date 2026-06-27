extends Component
class_name HoverComponent

# properties
@export var hoverScale : float = 1.2
@export var tweenDuration : float = .5
@export var tweenTransition : Tween.TransitionType = Tween.TRANS_CUBIC
@export var tweenEase : Tween.EaseType = Tween.EASE_OUT

func on_mouse_entered ():
	var tween = create_tween ()
	
	tween.set_trans (tweenTransition)
	tween.set_ease (tweenEase)
	tween.tween_property (get_parent (), "scale", Vector2 (hoverScale, hoverScale), tweenDuration)

func on_mouse_exit ():
	var tween = create_tween ()
	
	tween.set_trans (tweenTransition)
	tween.set_ease (tweenEase)
	tween.tween_property (get_parent (), "scale", Vector2 (1, 1), tweenDuration)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent = get_parent ()
	
	if not parent is Control:
		push_error ("Hover can only be a child of Control")
		queue_free ()
		return
		
	parent.mouse_entered.connect (on_mouse_entered)
	parent.mouse_exited.connect (on_mouse_exit)
