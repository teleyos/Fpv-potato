extends ColorRect

var offset = 100

func _ready():
	# Get the new size of the viewport (which is the window size)
	var new_size = get_tree().root.size
	rect_position = Vector2(
		(new_size.x - rect_size.x)/2 - offset,
		(new_size.y - rect_size.y)*0.95
	)
	# Connect the 'size_changed' signal of the root viewport to our callback function
	get_tree().root.connect("size_changed", self, "_on_viewport_resized")

func _on_viewport_resized():
	# Get the new size of the viewport (which is the window size)
	var new_size = get_tree().root.size
	rect_position = Vector2(
		(new_size.x - rect_size.x)/2 - offset,
		(new_size.y - rect_size.y)*0.95
	)
	# Add your resize handling code here
