# RichTextLabel2.gd (Godot 4.x)
extends RichTextLabel

func _process(_delta: float) -> void:
    var v := Input.get_vector("rleft", "rright", "rup", "rdown")
    text = "%.2f, %.2f" % [v.x, v.y]

