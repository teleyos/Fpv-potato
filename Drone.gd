extends CharacterBody3D

# Exposed defaults (used to generate a config if missing)
@export var thrust: float = 270.0
@export var rotation_speed: float = 4.0
@export var gravity_value: float = -80.0
@export var drag: float = 0.08
@export var max_velocity: float = 50.0  # New max velocity parameter
@export var spawn_transform: Transform3D = Transform3D.IDENTITY

# Where we store/read the config
const CONFIG_PATH: String = "user://drone.cfg"

var input_left: Vector2 = Vector2.ZERO
var input_right: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Use the scene-placed transform as the default spawn point for first run.
	var default_spawn: Transform3D = transform
	_load_or_create_config(default_spawn)

func _physics_process(delta: float) -> void:
	# Sticks / inputs (order: neg_x, pos_x, neg_y, pos_y)
	input_left  = Input.get_vector("ldown", "lup", "lright", "lleft")
	input_right = Input.get_vector("rdown", "rup", "rright", "rleft")

	# Recompute gravity each tick so edits from DebugUI take effect.
	var gravity: Vector3 = Vector3(0.0, gravity_value, 0.0)

	velocity += delta * (
		thrust * global_transform.basis.y * maxf(0.0, input_left.x)
		+ gravity
		- velocity * drag
	)
	
	# Apply max velocity limit
	if velocity.length() > max_velocity:
		velocity = velocity.normalized() * max_velocity

	# Direct rotation without acceleration/damping
	var rot_amount: float = rotation_speed * delta
	rotate_object_local(Vector3.RIGHT,    input_right.x * rot_amount)  # Pitch
	rotate_object_local(Vector3.UP,       input_left.y  * rot_amount)  # Yaw
	rotate_object_local(Vector3.FORWARD, -input_right.y * rot_amount)  # Roll

	# Kinematic step with collision stop.
	if move_and_collide(velocity * delta) != null:
		velocity = Vector3.ZERO

	# Reset to spawn.
	if Input.is_action_pressed("reset"):
		transform = spawn_transform
		rotation_degrees = Vector3.ZERO
		velocity = Vector3.ZERO

# --- Config I/O ---

func _load_or_create_config(default_spawn: Transform3D) -> void:
	var cfg: ConfigFile = ConfigFile.new()
	var err: Error = cfg.load(CONFIG_PATH)

	if err == OK:
		# Read values (typed casts protect against malformed configs)
		thrust = float(cfg.get_value("drone", "thrust", thrust))
		rotation_speed = float(cfg.get_value("drone", "rotation_speed", rotation_speed))
		gravity_value = float(cfg.get_value("drone", "gravity_value", gravity_value))
		drag = float(cfg.get_value("drone", "drag", drag))
		max_velocity = float(cfg.get_value("drone", "max_velocity", max_velocity))  # New config entry

		var st: Variant = cfg.get_value("drone", "spawn_transform", default_spawn)
		spawn_transform = st if st is Transform3D else default_spawn
	else:
		# Create config with current exports and the placed transform as spawn
		cfg.set_value("drone", "thrust", thrust)
		cfg.set_value("drone", "rotation_speed", rotation_speed)
		cfg.set_value("drone", "gravity_value", gravity_value)
		cfg.set_value("drone", "drag", drag)
		cfg.set_value("drone", "max_velocity", max_velocity)  # New config entry
		cfg.set_value("drone", "spawn_transform", default_spawn)

		var save_err: Error = cfg.save(CONFIG_PATH)
		if save_err != OK:
			push_warning("Failed to save default drone config to %s (err %d)" % [CONFIG_PATH, save_err])

		# Ensure runtime matches what we wrote
		spawn_transform = default_spawn

func save_config() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("drone", "thrust", thrust)
	cfg.set_value("drone", "rotation_speed", rotation_speed)
	cfg.set_value("drone", "gravity_value", gravity_value)
	cfg.set_value("drone", "drag", drag)
	cfg.set_value("drone", "max_velocity", max_velocity)  # New config entry
	cfg.set_value("drone", "spawn_transform", spawn_transform)

	var err: Error = cfg.save(CONFIG_PATH)
	if err != OK:
		push_warning("Failed to save drone config to %s (err %d)" % [CONFIG_PATH, err])
