extends Camera2D

var mousePos := get_global_mouse_position ()
var previousPos := get_global_mouse_position ()
var posDelta := Vector2 (0, 0)

func _process (_delta: float) -> void:
	
	mousePos = get_global_mouse_position ()
	posDelta = mousePos - previousPos
	previousPos = mousePos
	
	print (mousePos)
	self.translate (posDelta)
	
