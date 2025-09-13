extends KinematicBody

var thrust = 270
var angular_thrust = 30
var gravity_value = -80
var drag = 0.08
export var spawn = Vector3.ZERO

var gravity = Vector3(0,gravity_value,0)
var velocity = Vector3.ZERO
var angular_velocity = Vector3.ZERO
var input_left = Vector2.ZERO
var input_right = Vector2.ZERO

func _ready():
	spawn = transform
	pass 

func _physics_process(delta):
	input_left = Input.get_vector("ldown","lup","lright","lleft")
	input_right = Input.get_vector("rdown","rup","rright","rleft")
	
	velocity += delta * (
		thrust*global_transform.basis.y*max(0,input_left.x) + 
		gravity - 
		velocity*drag
	)
	
	var angular_acceleration = Vector3.ZERO
	
	angular_acceleration.x = input_right.x * angular_thrust  # Pitch (up/down)
	angular_acceleration.y = input_left.y * angular_thrust # Yaw (left/right)
	angular_acceleration.z = input_right.y * angular_thrust  # Roll (tilt)
	
	angular_velocity += angular_acceleration * delta
	
	rotate_object_local(Vector3.RIGHT, angular_velocity.x * delta)
	rotate_object_local(Vector3.UP, angular_velocity.y * delta)
	rotate_object_local(Vector3.FORWARD, -angular_velocity.z * delta)
	
	angular_velocity *= 0.95
	
	if move_and_collide(delta * velocity) :
		velocity = Vector3.ZERO
		
	
	if Input.is_action_pressed("reset"):
		transform = spawn
		rotation_degrees = Vector3.ZERO
		velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	pass
