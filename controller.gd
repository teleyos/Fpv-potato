extends MeshInstance2D

var half_size: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
    var container := get_parent() as Control
    if container == null:
        return

    # Control.rect_size -> Control.size in Godot 4
    half_size = container.size * 0.5

    var v := Input.get_vector("lleft", "lright", "lup", "ldown")
    # Map [-1..1] to [0..size], then nudge by half the dot size (5x5 -> 2.5)
    position = half_size * (Vector2.ONE + v) - Vector2(2.5, 2.5)

