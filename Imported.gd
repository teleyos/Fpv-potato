extends Node

# Use user directory for write access in compiled games
var imports_path = "user://imports/"

# Player/aircraft to move if it spawns inside the imported structure
export(float) var teleport_clearance = 2.0  # meters above the top surface
export(NodePath) var aircraft_path
onready var aircraft = get_node(aircraft_path) if aircraft_path else null

func _ready():
	# Create imports directory
	var dir = Directory.new()
	if dir.make_dir_recursive(imports_path) != OK:
		push_error("Could not create imports directory: " + imports_path)

func _unhandled_input(event):
	if event.is_action_pressed("import"):
		_show_import_menu()

func _show_import_menu():
	var popup_menu = PopupMenu.new()
	add_child(popup_menu)
	popup_menu.connect("popup_hide", popup_menu, "queue_free")
	
	# Scan directory
	var dir = Directory.new()
	if dir.open(imports_path) != OK:
		push_error("Could not open imports directory: " + imports_path)
		popup_menu.queue_free()
		return
	
	var filenames = []
	if dir.list_dir_begin(true, true) == OK:  # Skip . and .., skip hidden
		while true:
			var file = dir.get_next()
			if file == "":
				break
			if file.get_extension().to_lower() in ["gltf", "glb"]:
				filenames.append(file)
		dir.list_dir_end()
	
	if filenames.size() == 0:
		print("No GLTF files found in imports folder")
		popup_menu.queue_free()
		return
	
	for filename in filenames:
		popup_menu.add_item(filename)
	
	popup_menu.connect("id_pressed", self, "_on_file_selected", [filenames])
	popup_menu.popup_centered()

func _on_file_selected(id, filenames):
	if id < 0 or id >= filenames.size():
		return
	
	var selected_file = filenames[id]
	# Use Godot 3.x compatible path concatenation
	var path = imports_path
	if not path.ends_with("/"):
		path += "/"
	path += selected_file
	
	var scene = load_gltf(path)
	if scene:
		process_gltf_scene(scene)

# Universal GLTF loader for Godot 3
func load_gltf(path):
	# First try standard loader (works in editor)
	var scene_resource = load(path)
	if scene_resource and scene_resource is PackedScene:
		return scene_resource.instance()
	
	# Then try GLTFDocument method
	if ClassDB.class_exists("GLTFDocument") and ClassDB.class_exists("GLTFState"):
		var gltf = ClassDB.instance("GLTFDocument")
		var state = ClassDB.instance("GLTFState")
		
		if gltf.has_method("append_from_file") and state:
			if gltf.append_from_file(path, state) == OK:
				return gltf.generate_scene(state)
	
	# Finally try PackedSceneGLTF as fallback
	if ClassDB.class_exists("PackedSceneGLTF"):
		var gltf_loader = ClassDB.instance("PackedSceneGLTF")
		if gltf_loader.has_method("import_gltf_scene"):
			return gltf_loader.import_gltf_scene(path, 0, 1000, 0)
	
	push_error("Failed to load GLTF: " + path)
	return null

# --- Collision generation + teleport if inside ---

func process_gltf_scene(scene):
	# Add the visual scene immediately
	add_child(scene)

	# Compute world-space AABB of the imported visuals
	var aabb = _get_world_aabb(scene)

	# If the aircraft exists and is inside the imported structure, move it on top
	if aabb and aircraft and aircraft is Spatial:
		var p = aircraft.global_transform.origin
		if aabb.has_point(p):
			p.y = aabb.position.y + aabb.size.y + teleport_clearance
			var t = aircraft.global_transform
			t.origin = p
			aircraft.global_transform = t
			aircraft.spawn = t
			# Optional: if aircraft is a RigidBody, you may also want to clear its velocity:
			# if aircraft is RigidBody:
			#     aircraft.linear_velocity = Vector3()
			#     aircraft.angular_velocity = Vector3()

	# Create accurate, per-mesh static colliders beside the visual scene
	var col_root = Node.new()
	col_root.name = scene.name + "_colliders"
	add_child(col_root)
	_add_trimesh_collision_recursive(scene, col_root)

# Build concave collisions for each MeshInstance (static geometry)
func _add_trimesh_collision_recursive(root, into_parent):
	for child in root.get_children():
		if child is MeshInstance:
			_create_static_trimesh_body(child, into_parent)
		if child is Spatial:
			_add_trimesh_collision_recursive(child, into_parent)

func _create_static_trimesh_body(mi: MeshInstance, into_parent: Node):
	if mi.mesh == null:
		return
	
	var sb = StaticBody.new()
	sb.name = mi.name + "_StaticBody"
	sb.transform = mi.global_transform

	var cs = CollisionShape.new()
	cs.shape = mi.mesh.create_trimesh_shape()  # ConcavePolygonShape (static only)
	sb.add_child(cs)

	into_parent.add_child(sb)
	# sb.collision_layer = 1
	# sb.collision_mask  = 1

# Compute merged world-space AABB of all MeshInstances under root
func _get_world_aabb(root):
	var first = true
	var merged = AABB()
	var stack = [root]
	while stack.size() > 0:
		var n = stack.pop_back()
		if n is MeshInstance:
			var local_aabb = n.get_aabb()
			var world_aabb = n.global_transform.xform(local_aabb)
			if first:
				merged = world_aabb
				first = false
			else:
				merged = merged.merge(world_aabb)
		if n is Spatial:
			for c in n.get_children():
				stack.append(c)
	# Return null if no meshes found
	return merged if not first else null
