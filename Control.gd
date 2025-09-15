# Control.gd (Godot 4.x)
extends ColorRect

@export var aircraft_path: NodePath
@onready var aircraft: Node3D = get_node_or_null(aircraft_path) as Node3D

var center: Vector2 = Vector2.ZERO
var amplitude: float = 169.0

func _ready() -> void:
    # Viewport size change signal (4.x)
    get_viewport().size_changed.connect(_on_viewport_resized)

    var new_size: Vector2i = get_viewport().size
    center = Vector2(
        (new_size.x - size.x) / 2.0,
        (new_size.y - size.y) / 2.0
    )
    position = center
    amplitude = float(new_size.y) / 4.0

func _on_viewport_resized() -> void:
    var new_size: Vector2i = get_viewport().size
    center = Vector2(
        (new_size.x - size.x) / 2.0,
        (new_size.y - size.y) / 2.0
    )
    position.x = center.x
    amplitude = float(new_size.y) / 4.0

func _process(_delta: float) -> void:
    queue_redraw()  # 4.x name

func _draw() -> void:
    if aircraft == null:
        return
    # UI roll from aircraft Z, UI vertical offset from aircraft X (degrees).
    rotation_degrees = aircraft.rotation_degrees.z
    position.y = center.y + (amplitude * aircraft.rotation_degrees.x / 180.0)

