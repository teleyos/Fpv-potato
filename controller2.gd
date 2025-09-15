extends MeshInstance2D

var half_size: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
    var container := get_parent() as Control
    if container == null:
        return

    half_size = container.size * 0.5

    var v := Input.get_vector("rleft", "rright", "rup", "rdown")
    position = half_size * (Vector2.ONE + v) - Vector2(2.5, 2.5)

