extends Camera


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("arrow_down"):
		rotation_degrees.x -= 1
		
	if Input.is_action_just_pressed("arrow_up"):
		rotation_degrees.x += 1
			
	if Input.is_action_pressed("plus"):
		fov += 1
	if Input.is_action_pressed("minus"):
		fov -= 1
	pass
