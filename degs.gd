extends RichTextLabel

@export_node_path("Node3D") var cam_path: NodePath
@onready var cam: Node3D = get_node_or_null(cam_path) as Node3D

func _ready() -> void:
	_reposition()
	var win := get_window()
	if win:
		win.size_changed.connect(_on_window_resized)

func _on_window_resized() -> void:
	_reposition()

func _reposition() -> void:
	var win := get_window()
	if win == null:
		return
	var ws: Vector2 = Vector2(win.size)
	position = Vector2(
		(ws.x - size.x) * 0.5,
		(ws.y - size.y) * 0.95
	)

func _process(_delta: float) -> void:
	if cam == null:
		return
	text = "%d°" % [int(round(cam.rotation_degrees.x))]
