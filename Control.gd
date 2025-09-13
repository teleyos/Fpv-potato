extends ColorRect

export(NodePath) var aircraft_path
onready var aircraft = get_node(aircraft_path) if aircraft_path else null

var center = Vector2.ZERO
var amplitude = 169

func _ready():
	# Connect the 'size_changed' signal of the root viewport to our callback function
	get_tree().root.connect("size_changed", self, "_on_viewport_resized")
	var new_size = get_tree().root.size
	center = Vector2(
		(new_size.x - rect_size.x)/2,
		(new_size.y - rect_size.y)/2
	)
	rect_position.x = center.x
	rect_position.y = center.y
	amplitude = new_size.y / 4

func _on_viewport_resized():
	# Get the new size of the viewport (which is the window size)
	var new_size = get_tree().root.size
	center = Vector2(
		(new_size.x - rect_size.x)/2,
		(new_size.y - rect_size.y)/2
	)
	rect_position.x = center.x
	amplitude = new_size.y / 4

func _process(_delta):
	update()  # Redraw every frame

func _draw():
	if !aircraft:
		return

	rect_rotation = aircraft.rotation_degrees.z
	rect_position.y = center.y + (amplitude*aircraft.rotation_degrees.x/180)
