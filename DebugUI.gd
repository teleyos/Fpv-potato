extends CanvasLayer

# Use a node reference instead of NodePath
export(NodePath) var target_node = null

# Slider references
onready var thrust_slider = $PanelContainer/VBoxContainer/Thrust/HSlider
onready var angular_slider = $PanelContainer/VBoxContainer/AngularThrust/HSlider
onready var gravity_slider = $PanelContainer/VBoxContainer/Gravity/HSlider
onready var drag_slider = $PanelContainer/VBoxContainer/Drag/HSlider

# Value labels
onready var thrust_value = $PanelContainer/VBoxContainer/Thrust/LabelValue
onready var angular_value = $PanelContainer/VBoxContainer/AngularThrust/LabelValue
onready var gravity_value_label = $PanelContainer/VBoxContainer/Gravity/LabelValue
onready var drag_value = $PanelContainer/VBoxContainer/Drag/LabelValue

func _ready():
	# Ensure target node is ready
	call_deferred("initialize_sliders")

func initialize_sliders():
	if !target_node or !is_instance_valid(target_node):
		push_error("DebugUI: Target node is invalid or not set")
		return
	
	# Initialize slider values
	thrust_slider.value = target_node.thrust
	angular_slider.value = target_node.angular_thrust
	gravity_slider.value = target_node.gravity_value
	drag_slider.value = target_node.drag * 100  # Convert to percentage
	
	# Update initial labels
	_on_Thrust_value_changed(target_node.thrust)
	_on_Angular_value_changed(target_node.angular_thrust)
	_on_Gravity_value_changed(target_node.gravity_value)
	_on_Drag_value_changed(target_node.drag * 100)

func _on_Thrust_value_changed(value):
	if is_instance_valid(target_node):
		target_node.thrust = value
		thrust_value.text = "%.1f" % value

func _on_Angular_value_changed(value):
	if is_instance_valid(target_node):
		target_node.angular_thrust = value
		angular_value.text = "%.1f" % value

func _on_Gravity_value_changed(value):
	if is_instance_valid(target_node):
		target_node.gravity_value = value
		gravity_value_label.text = "%.1f" % value

func _on_Drag_value_changed(value):
	if is_instance_valid(target_node):
		var actual_value = value / 100.0
		target_node.drag = actual_value
		drag_value.text = "%.3f" % actual_value

func _input(event):
	if event.is_action_pressed("ui_debug"):
		$PanelContainer.visible = !$PanelContainer.visible
