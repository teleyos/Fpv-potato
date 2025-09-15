# Imported.gd (Godot 4.x)
extends Node

# Use user directory for write access in exported games.
var imports_path: String = "user://imports"

@export var teleport_clearance: float = 2.0  # meters above the top surface
@export var aircraft_path: NodePath
@onready var aircraft: Node3D = get_node_or_null(aircraft_path) as Node3D

# Keep references to last import so we can delete them on next import
var imported_visual_root: Node = null
var imported_collision_root: Node3D = null

func _ready() -> void:
	# Create imports directory (recursive, absolute).
	var err: Error = DirAccess.make_dir_recursive_absolute(imports_path)
	if err != OK:
		push_error("Could not create imports directory: %s (err %d)" % [imports_path, err])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("import"):
		_show_import_menu()

func _show_import_menu() -> void:
	var popup_menu: PopupMenu = PopupMenu.new()
	add_child(popup_menu)

	# Auto-free when closed.
	popup_menu.popup_hide.connect(func() -> void:
		popup_menu.queue_free()
	)

	# Scan directory for .gltf/.glb
	var dir: DirAccess = DirAccess.open(imports_path)
	if dir == null:
		push_error("Could not open imports directory: %s" % imports_path)
		popup_menu.queue_free()
		return

	dir.include_hidden = false
	dir.include_navigational = false
	dir.list_dir_begin()
	var filenames: Array[String] = []
	while true:
		var file: String = dir.get_next()
		if file == "":
			break
		if not dir.current_is_dir():
			var ext: String = file.get_extension().to_lower()
			if ext == "gltf" or ext == "glb":
				filenames.append(file)
	dir.list_dir_end()

	if filenames.is_empty():
		print("No GLTF files found in imports folder")
		popup_menu.queue_free()
		return

	for filename in filenames:
		popup_menu.add_item(filename)

	# When user picks an item, load that file.
	popup_menu.id_pressed.connect(func(id: int) -> void:
		_on_file_selected(id, filenames)
	)

	popup_menu.popup_centered()

func _on_file_selected(id: int, filenames: Array[String]) -> void:
	if id < 0 or id >= filenames.size():
		return

	var selected_file: String = filenames[id]
	var path: String = imports_path.path_join(selected_file)

	var scene_node: Node = load_gltf(path)
	if scene_node:
		process_gltf_scene(scene_node)

# --- Runtime GLTF loading (user:// friendly) ---

func load_gltf(path: String) -> Node:
	if ClassDB.class_exists("GLTFDocument") and ClassDB.class_exists("GLTFState"):
		var gltf: GLTFDocument = GLTFDocument.new()
		var state: GLTFState = GLTFState.new()
		var err: Error = gltf.append_from_file(path, state)  # imports .gltf/.glb at runtime
		if err == OK:
			return gltf.generate_scene(state)  # returns a scene root Node/Node3D
	# If we get here, loading failed.
	push_error("Failed to load GLTF: %s" % path)
	return null

# --- Collision generation + teleport if inside ---

func process_gltf_scene(scene: Node) -> void:
	# 1) Clear previous import (visuals + colliders), if any
	_clear_previous_import()

	# 2) Add the new visual scene
	add_child(scene)
	imported_visual_root = scene

	# 3) Compute world-space AABB of the imported visuals
	var aabb_v: Variant = _get_world_aabb(scene)

	# 4) If the aircraft exists and is inside the imported structure, move it on top
	if aircraft and aabb_v is AABB:
		var aabb: AABB = aabb_v
		var p: Vector3 = aircraft.global_transform.origin
		if aabb.has_point(p):
			p.y = aabb.position.y + aabb.size.y + teleport_clearance
			var t: Transform3D = aircraft.global_transform
			t.origin = p
			aircraft.global_transform = t
			# Keep spawn in sync with Drone.gd (Godot 4 port uses `spawn_transform`)
			if aircraft.has_method("get_property_list"):
				for prop in aircraft.get_property_list():
					if typeof(prop) == TYPE_DICTIONARY and prop.get("name", "") == "spawn_transform":
						aircraft.set("spawn_transform", t)
						break

	# 5) Create accurate, per-mesh static colliders beside the visual scene
	var col_root: Node3D = Node3D.new()
	col_root.name = "%s_colliders" % scene.name
	add_child(col_root)
	imported_collision_root = col_root
	_add_trimesh_collision_recursive(scene, col_root)

func _clear_previous_import() -> void:
	# Delete previous colliders first (cheap to rebuild, and avoids lingering physics)
	if imported_collision_root and is_instance_valid(imported_collision_root):
		imported_collision_root.queue_free()
		imported_collision_root = null
	# Then delete the previous visual scene
	if imported_visual_root and is_instance_valid(imported_visual_root):
		imported_visual_root.queue_free()
		imported_visual_root = null

# Build concave collisions for each MeshInstance3D (static geometry)
func _add_trimesh_collision_recursive(root: Node, into_parent: Node3D) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			_create_static_trimesh_body(child as MeshInstance3D, into_parent)
		if child is Node3D:
			_add_trimesh_collision_recursive(child, into_parent)

func _create_static_trimesh_body(mi: MeshInstance3D, into_parent: Node3D) -> void:
	if mi.mesh == null:
		return

	var sb: StaticBody3D = StaticBody3D.new()
	sb.name = "%s_StaticBody" % mi.name
	into_parent.add_child(sb)
	# Preserve world transform after parenting
	sb.global_transform = mi.global_transform

	var cs: CollisionShape3D = CollisionShape3D.new()
	cs.shape = mi.mesh.create_trimesh_shape()  # ConcavePolygonShape3D (static only)
	sb.add_child(cs)

	# If needed:
	# sb.collision_layer = 1
	# sb.collision_mask  = 1

# Compute merged world-space AABB of all MeshInstance3Ds under root
func _get_world_aabb(root: Node) -> Variant:
	var first: bool = true
	var merged: AABB = AABB()
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var local_aabb: AABB = (n as MeshInstance3D).get_aabb()
			var world_aabb: AABB = (n as MeshInstance3D).global_transform * local_aabb
			if first:
				merged = world_aabb
				first = false
			else:
				merged = merged.merge(world_aabb)
		if n is Node3D:
			for c in n.get_children():
				stack.append(c)
	return merged if not first else null
