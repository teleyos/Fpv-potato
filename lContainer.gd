extends ColorRect

@export var offset: float = 100.0

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
    # Control.rect_position -> position, Control.rect_size -> size in Godot 4
    position = Vector2(
        (ws.x - size.x) * 0.5 - offset,
        (ws.y - size.y) * 0.95
    )

