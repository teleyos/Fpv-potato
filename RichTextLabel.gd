# RichTextLabel.gd (Godot 4.x)
extends RichTextLabel

func _ready() -> void:
    # If you plan to use BBCode tags, enable this:
    # bbcode_enabled = true
    pass

func _process(_delta: float) -> void:
    # Correct order: neg_x, pos_x, neg_y, pos_y
    var v := Input.get_vector("lleft", "lright", "lup", "ldown")
    text = "%.2f, %.2f" % [v.x, v.y]

