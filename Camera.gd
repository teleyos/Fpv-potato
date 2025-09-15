extends Camera3D

@export var rotate_step: float = 1.0
@export var fov_step: float = 1.0
@export var fov_min: float = 1.0
@export var fov_max: float = 179.0

const CONFIG_PATH: String = "user://drone.cfg"

var _pending_fov_save: bool = false

func _ready() -> void:
	_load_or_create_fov()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("arrow_down"):
		rotation_degrees.x -= rotate_step
	if Input.is_action_just_pressed("arrow_up"):
		rotation_degrees.x += rotate_step

	var changed := false
	if Input.is_action_pressed("plus"):
		fov += fov_step
		changed = true
	if Input.is_action_pressed("minus"):
		fov -= fov_step
		changed = true

	if changed:
		fov = clamp(fov, fov_min, fov_max)
		_pending_fov_save = true

	# Save once when the user releases the key(s) that changed the FOV.
	if _pending_fov_save and (Input.is_action_just_released("plus") or Input.is_action_just_released("minus")):
		_save_fov()
		_pending_fov_save = false

func _exit_tree() -> void:
	# Persist any unsaved change on exit.
	if _pending_fov_save:
		_save_fov()
		_pending_fov_save = false

# --- Config I/O ---

func _load_or_create_fov() -> void:
	var cfg := ConfigFile.new()
	var err: Error = cfg.load(CONFIG_PATH)
	if err == OK:
		var v: Variant = cfg.get_value("camera", "fov", fov)
		# Guard against malformed config
		var fv := (v as float) if (typeof(v) == TYPE_FLOAT or typeof(v) == TYPE_INT) else fov
		fov = clamp(fv, fov_min, fov_max)
	else:
		# First run: write current FOV as default
		cfg.set_value("camera", "fov", clamp(fov, fov_min, fov_max))
		var save_err: Error = cfg.save(CONFIG_PATH)
		if save_err != OK:
			push_warning("Failed to save default camera config to %s (err %d)" % [CONFIG_PATH, save_err])

func _save_fov() -> void:
	var cfg := ConfigFile.new()
	var err: Error = cfg.load(CONFIG_PATH)
	# If the file doesn't exist or failed to load, start new; this won't erase the drone section if load succeeds.
	if err != OK:
		cfg = ConfigFile.new()
	# Preserve existing sections/values when possible
	else:
		# cfg already has the existing content
		pass
	cfg.set_value("camera", "fov", clamp(fov, fov_min, fov_max))
	var save_err: Error = cfg.save(CONFIG_PATH)
	if save_err != OK:
		push_warning("Failed to save camera FOV to %s (err %d)" % [CONFIG_PATH, save_err])
