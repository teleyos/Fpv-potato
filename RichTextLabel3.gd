# RichTextLabel3.gd (Godot 4.x)
extends RichTextLabel

func _ready() -> void:
    text = (
        """h to show/hide this tooltip
i to import .glb from %s/imports/
up/down controller arrows to adjust cam angle
right action button on controller to respawn
p/m to adjust FOV""" % [OS.get_user_data_dir()]
    ).strip_edges()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("help"):
        visible = not visible
        accept_event()

