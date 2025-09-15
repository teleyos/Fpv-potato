# DebugUI.gd (Godot 4.x)
extends CanvasLayer

@export var target_node_path: NodePath
@onready var target_node: Node = get_node_or_null(target_node_path)

# Slider references
@onready var thrust_slider: HSlider  = $PanelContainer/VBoxContainer/Thrust/HSlider
@onready var angular_slider: HSlider = $PanelContainer/VBoxContainer/AngularThrust/HSlider
@onready var gravity_slider: HSlider = $PanelContainer/VBoxContainer/Gravity/HSlider
@onready var drag_slider: HSlider    = $PanelContainer/VBoxContainer/Drag/HSlider

# Value labels
@onready var thrust_value: Label         = $PanelContainer/VBoxContainer/Thrust/LabelValue
@onready var angular_value: Label        = $PanelContainer/VBoxContainer/AngularThrust/LabelValue
@onready var gravity_value_label: Label  = $PanelContainer/VBoxContainer/Gravity/LabelValue
@onready var drag_value: Label           = $PanelContainer/VBoxContainer/Drag/LabelValue

func _ready() -> void:
    # Ensure the target node is in the tree before reading its properties.
    call_deferred("initialize_sliders")

func initialize_sliders() -> void:
    if target_node == null or !is_instance_valid(target_node):
        push_error("DebugUI: Target node is invalid or not set")
        return

    # Initialize slider values from the target
    thrust_slider.value  = target_node.thrust
    angular_slider.value = target_node.angular_thrust
    gravity_slider.value = target_node.gravity_value
    drag_slider.value    = target_node.drag * 100.0  # Convert to percentage

    # Update initial labels
    _on_Thrust_value_changed(thrust_slider.value)
    _on_Angular_value_changed(angular_slider.value)
    _on_Gravity_value_changed(gravity_slider.value)
    _on_Drag_value_changed(drag_slider.value)

func _on_Thrust_value_changed(value: float) -> void:
    if is_instance_valid(target_node):
        target_node.thrust = value
        thrust_value.text = "%.1f" % value

func _on_Angular_value_changed(value: float) -> void:
    if is_instance_valid(target_node):
        target_node.angular_thrust = value
        angular_value.text = "%.1f" % value

func _on_Gravity_value_changed(value: float) -> void:
    if is_instance_valid(target_node):
        target_node.gravity_value = value
        gravity_value_label.text = "%.1f" % value

func _on_Drag_value_changed(value: float) -> void:
    if is_instance_valid(target_node):
        var actual_value := value / 100.0
        target_node.drag = actual_value
        drag_value.text = "%.3f" % actual_value

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_debug"):
        $PanelContainer.visible = !$PanelContainer.visible

