extends CharacterBody3D

# ============================================================
# MAGE RPG - PROCEDURAL HUMANOID PLAYER
# ============================================================

@export var move_speed: float = 4.8
@export var run_speed: float = 7.2
@export var acceleration: float = 18.0
@export var rotation_speed: float = 10.0
@export var gravity: float = 20.0

@export var max_hp: int = 100
@export var max_mana: int = 100

var hp: int = 100
var mana: int = 100
var xp: int = 0
var level: int = 1

var joystick_input := Vector2.ZERO
var external_input := Vector2.ZERO

var camera: Camera3D
var model: Node3D
var skeleton_root: Node3D

var torso: Node3D
var head: Node3D
var hair: Node3D

var arm_l: Node3D
var arm_r: Node3D
var forearm_l: Node3D
var forearm_r: Node3D

var hand_l: Node3D
var hand_r: Node3D

var leg_l: Node3D
var leg_r: Node3D
var foot_l: Node3D
var foot_r: Node3D

var robe: Node3D
var cloak: Node3D
var belt: Node3D

var staff: Node3D
var staff_crystal: MeshInstance3D
var magic_light: OmniLight3D

var spell_cooldown := 0.0
var cast_timer := 0.0

var animation_time := 0.0
var current_speed := 0.0

var facing_direction := Vector3(0, 0, 1)

var body_material: StandardMaterial3D
var robe_material: StandardMaterial3D
var dark_material: StandardMaterial3D
var skin_material: StandardMaterial3D
var leather_material: StandardMaterial3D
var gold_material: StandardMaterial3D
var magic_material: StandardMaterial3D
var hair_material: StandardMaterial3D


func _ready() -> void:
	hp = max_hp
	mana = max_mana

	create_physics()

	model = Node3D.new()
	model.name = "MageModel"
	add_child(model)

	create_character()

	create_camera()


# ============================================================
# PHYSICS
# ============================================================

func create_physics() -> void:
	var collision := CollisionShape3D.new()
	collision.name = "PlayerCollision"

	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.75

	collision.shape = capsule
	collision.position.y = 0.95

	add_child(collision)


# ============================================================
# MATERIALS
# ============================================================

func create_materials() -> void:

	body_material = StandardMaterial3D.new()
	body_material.albedo_color = Color(0.12, 0.15, 0.22)
	body_material.roughness = 0.72

	robe_material = StandardMaterial3D.new()
	robe_material.albedo_color = Color(0.055, 0.035, 0.11)
	robe_material.roughness = 0.9

	dark_material = StandardMaterial3D.new()
	dark_material.albedo_color = Color(0.018, 0.02, 0.035)
	dark_material.roughness = 0.82

	skin_material = StandardMaterial3D.new()
	skin_material.albedo_color = Color(0.72, 0.47, 0.34)
	skin_material.roughness = 0.8

	leather_material = StandardMaterial3D.new()
	leather_material.albedo_color = Color(0.17, 0.075, 0.035)
	leather_material.roughness = 0.92

	gold_material = StandardMaterial3D.new()
	gold_material.albedo_color = Color(0.72, 0.43, 0.12)
	gold_material.metallic = 0.55
	gold_material.roughness = 0.3

	magic_material = StandardMaterial3D.new()
	magic_material.albedo_color = Color(0.15, 0.55, 1.0)
	magic_material.emission_enabled = true
	magic_material.emission = Color(0.08, 0.38, 1.0)
	magic_material.emission_energy_multiplier = 5.0
	magic_material.roughness = 0.15

	hair_material = StandardMaterial3D.new()
	hair_material.albedo_color = Color(0.025, 0.018, 0.035)
	hair_material.roughness = 0.65


# ============================================================
# CHARACTER
# ============================================================

func create_character() -> void:

	create_materials()

	skeleton_root = Node3D.new()
	skeleton_root.name = "BodyRig"
	model.add_child(skeleton_root)

	# ---------------- BODY ----------------

	torso = create_capsule(
		"Torso",
		0.42,
		0.95,
		skin_material
	)

	torso.position = Vector3(0, 1.48, 0)
	torso.scale = Vector3(1.0, 1.05, 0.62)
	skeleton_root.add_child(torso)

	# ---------------- NECK ----------------

	var neck := create_cylinder(
		"Neck",
		0.17,
		0.22,
		skin_material
	)

	neck.position = Vector3(0, 2.03, 0)
	skeleton_root.add_child(neck)

	# ---------------- HEAD ----------------

	head = Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 2.34, 0)
	skeleton_root.add_child(head)

	var head_mesh := create_uv_sphere(
		"HeadMesh",
		0.34,
		skin_material
	)

	head_mesh.scale = Vector3(0.88, 1.08, 0.88)
	head.add_child(head_mesh)

	# ---------------- EARS ----------------

	var ear_l := create_uv_sphere(
		"EarL",
		0.085,
		skin_material
	)

	ear_l.position = Vector3(-0.31, 0.01, 0)
	head.add_child(ear_l)

	var ear_r := create_uv_sphere(
		"EarR",
		0.085,
		skin_material
	)

	ear_r.position = Vector3(0.31, 0.01, 0)
	head.add_child(ear_r)

	# ---------------- NOSE ----------------

	var nose := create_uv_sphere(
		"Nose",
		0.065,
		skin_material
	)

	nose.position = Vector3(0, -0.015, 0.32)
	nose.scale = Vector3(0.75, 0.7, 1.4)
	head.add_child(nose)

	# ---------------- EYES ----------------

	var eye_l := create_uv_sphere(
		"EyeL",
		0.045,
		Color(0.45, 0.8, 1.0)
	)

	eye_l.position = Vector3(-0.12, 0.075, 0.29)
	head.add_child(eye_l)

	var eye_r := create_uv_sphere(
		"EyeR",
		0.045,
		Color(0.45, 0.8, 1.0)
	)

	eye_r.position = Vector3(0.12, 0.075, 0.29)
	head.add_child(eye_r)

	# ---------------- HAIR ----------------

	hair = Node3D.new()
	hair.name = "Hair"
	hair.position = Vector3(0, 0.12, -0.03)
	head.add_child(hair)

	var hair_top := create_uv_sphere(
		"HairTop",
		0.34,
		hair_material
	)

	hair_top.scale = Vector3(1.02, 0.65, 1.0)
	hair_top.position.y = 0.12
	hair.add_child(hair_top)

	for i in range(5):
		var strand := create_capsule(
			"HairStrand" + str(i),
			0.045,
			0.34,
			hair_material
		)

		strand.position = Vector3(
			-0.2 + i * 0.1,
			-0.12,
			-0.03
		)

		hair.add_child(strand)

	# ---------------- ROBE ----------------

	robe = Node3D.new()
	robe.name = "LongRobe"
	robe.position = Vector3(0, 1.15, 0)
	skeleton_root.add_child(robe)

	var robe_mesh := create_cylinder(
		"RobeBody",
		0.63,
		1.55,
		robe_material
	)

	robe_mesh.position.y = 0.15
	robe_mesh.scale = Vector3(1.0, 1.0, 0.78)
	robe.add_child(robe_mesh)

	# robe lower decorative layer
	var robe_bottom := create_cylinder(
		"RobeBottom",
		0.72,
		0.36,
		dark_material
	)

	robe_bottom.position.y = -0.55
	robe.add_child(robe_bottom)

	# ---------------- CLOAK ----------------

	cloak = Node3D.new()
	cloak.name = "Cloak"
	cloak.position = Vector3(0, 1.72, -0.18)
	skeleton_root.add_child(cloak)

	var cloak_mesh := create_uv_sphere(
		"CloakShape",
		0.55,
		dark_material
	)

	cloak_mesh.scale = Vector3(1.05, 1.1, 0.42)
	cloak.add_child(cloak_mesh)

	# ---------------- SHOULDERS ----------------

	var shoulder_l := create_uv_sphere(
		"ShoulderL",
		0.22,
		robe_material
	)

	shoulder_l.position = Vector3(-0.48, 1.75, 0)
	skeleton_root.add_child(shoulder_l)

	var shoulder_r := create_uv_sphere(
		"ShoulderR",
		0.22,
		robe_material
	)

	shoulder_r.position = Vector3(0.48, 1.75, 0)
	skeleton_root.add_child(shoulder_r)

	# ---------------- ARMS ----------------

	arm_l = create_capsule(
		"ArmL",
		0.115,
		0.62,
		robe_material
	)

	arm_l.position = Vector3(-0.54, 1.46, 0)
	arm_l.rotation.z = -0.15
	skeleton_root.add_child(arm_l)

	arm_r = create_capsule(
		"ArmR",
		0.115,
		0.62,
		robe_material
	)

	arm_r.position = Vector3(0.54, 1.46, 0)
	arm_r.rotation.z = 0.15
	skeleton_root.add_child(arm_r)

	# ---------------- FOREARMS ----------------

	forearm_l = create_capsule(
		"ForearmL",
		0.095,
		0.52,
		leather_material
	)

	forearm_l.position = Vector3(-0.61, 1.08, 0.03)
	forearm_l.rotation.z = -0.12
	skeleton_root.add_child(forearm_l)

	forearm_r = create_capsule(
		"ForearmR",
		0.095,
		0.52,
		leather_material
	)

	forearm_r.position = Vector3(0.61, 1.08, 0.03)
	forearm_r.rotation.z = 0.12
	skeleton_root.add_child(forearm_r)

	# ---------------- HANDS ----------------

	hand_l = create_uv_sphere(
		"HandL",
		0.11,
		skin_material
	)

	hand_l.position = Vector3(-0.64, 0.79, 0.04)
	skeleton_root.add_child(hand_l)

	hand_r = create_uv_sphere(
		"HandR",
		0.11,
		skin_material
	)

	hand_r.position = Vector3(0.64, 0.79, 0.04)
	skeleton_root.add_child(hand_r)

	# ---------------- LEGS ----------------

	leg_l = create_capsule(
		"LegL",
		0.15,
		0.72,
		dark_material
	)

	leg_l.position = Vector3(-0.22, 0.55, 0)
	skeleton_root.add_child(leg_l)

	leg_r = create_capsule(
		"LegR",
		0.15,
		0.72,
		dark_material
	)

	leg_r.position = Vector3(0.22, 0.55, 0)
	skeleton_root.add_child(leg_r)

	# ---------------- FEET ----------------

	foot_l = create_capsule(
		"FootL",
		0.13,
		0.45,
		leather_material
	)

	foot_l.position = Vector3(-0.22, 0.16, 0.13)
	foot_l.rotation.x = PI / 2.0
	skeleton_root.add_child(foot_l)

	foot_r = create_capsule(
		"FootR",
		0.13,
		0.45,
		leather_material
	)

	foot_r.position = Vector3(0.22, 0.16, 0.13)
	foot_r.rotation.x = PI / 2.0
	skeleton_root.add_child(foot_r)

	# ---------------- BELT ----------------

	belt = Node3D.new()
	belt.name = "Belt"
	belt.position = Vector3(0, 1.18, 0)
	skeleton_root.add_child(belt)

	var belt_mesh := create_torus(
		"LeatherBelt",
		0.55,
		0.055,
		leather_material
	)

	belt_mesh.rotation.x = PI / 2.0
	belt.add_child(belt_mesh)

	# ---------------- BELT BUCKLE ----------------

	var buckle := create_box(
		"Buckle",
		Vector3(0.13, 0.15, 0.045),
		gold_material
	)

	buckle.position = Vector3(0, 0, 0.56)
	belt.add_child(buckle)

	# ---------------- HOOD ----------------

	var hood := create_uv_sphere(
		"Hood",
		0.42,
		robe_material
	)

	hood.position = Vector3(0, 2.42, -0.03)
	hood.scale = Vector3(1.08, 0.9, 1.0)
	skeleton_root.add_child(hood)

	# face opening
	var hood_inner := create_uv_sphere(
		"HoodOpening",
		0.3,
		dark_material
	)

	hood_inner.position = Vector3(0, 2.38, 0.26)
	hood_inner.scale = Vector3(1.0, 0.9, 0.35)
	skeleton_root.add_child(hood_inner)

	# ---------------- STAFF ----------------

	create_staff()


# ============================================================
# STAFF
# ============================================================

func create_staff() -> void:

	staff = Node3D.new()
	staff.name = "MagicStaff"

	staff.position = Vector3(0.84, 0.85, 0.02)
	staff.rotation.z = -0.04

	model.add_child(staff)

	var shaft := create_cylinder(
		"StaffWood",
		0.055,
		2.65,
		leather_material
	)

	shaft.position.y = 0.85
	staff.add_child(shaft)

	var top := create_uv_sphere(
		"StaffTop",
		0.14,
		leather_material
	)

	top.position.y = 2.18
	staff.add_child(top)

	staff_crystal = create_uv_sphere(
		"Crystal",
		0.13,
		magic_material
	)

	staff_crystal.position.y = 2.35
	staff_crystal.scale = Vector3(0.75, 1.45, 0.75)
	staff.add_child(staff_crystal)

	magic_light = OmniLight3D.new()
	magic_light.name = "MagicLight"
	magic_light.light_color = Color(0.15, 0.5, 1.0)
	magic_light.light_energy = 1.6
	magic_light.omni_range = 4.0
	magic_light.position = Vector3(0, 2.35, 0)

	staff.add_child(magic_light)


# ============================================================
# CAMERA
# ============================================================

func create_camera() -> void:

	camera = Camera3D.new()
	camera.name = "Camera3D"

	camera.position = Vector3(0, 3.5, 7.5)
	camera.rotation_degrees.x = -14.0

	camera.current = true
	camera.fov = 68.0

	add_child(camera)


func update_camera(delta: float) -> void:

	if camera == null:
		return

	var target := global_position + Vector3(0, 1.4, 0)

	var desired := target + Vector3(
		0,
		3.4,
		7.4
	)

	camera.global_position = camera.global_position.lerp(
		desired,
		min(delta * 5.0, 1.0)
	)

	camera.look_at(target, Vector3.UP)


# ============================================================
# PROCESS
# ============================================================

func _physics_process(delta: float) -> void:

	if spell_cooldown > 0.0:
		spell_cooldown -= delta

	if cast_timer > 0.0:
		cast_timer -= delta

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var input_vector := joystick_input

	if input_vector.length_squared() < 0.01:
		input_vector = external_input

	if input_vector.length_squared() < 0.01:
		input_vector = Input.get_vector(
			"ui_left",
			"ui_right",
			"ui_up",
			"ui_down"
		)

	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	var direction := Vector3(
		input_vector.x,
		0.0,
		input_vector.y
	)

	var target_speed := 0.0

	if direction.length_squared() > 0.01:

		target_speed = move_speed

		if Input.is_action_pressed("ui_accept"):
			target_speed = run_speed

		current_speed = move_toward(
			current_speed,
			target_speed,
			acceleration * delta
		)

		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

		var target_rotation := atan2(
			direction.x,
			direction.z
		)

		rotation.y = lerp_angle(
			rotation.y,
			target_rotation,
			min(rotation_speed * delta, 1.0)
		)

		facing_direction = direction

	else:

		current_speed = move_toward(
			current_speed,
			0.0,
			acceleration * delta
		)

		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			0.0,
			acceleration * delta
		)

	move_and_slide()

	animation_time += delta

	update_animation(delta)
	update_camera(delta)


# ============================================================
# PROCEDURAL ANIMATION
# ============================================================

func update_animation(delta: float) -> void:

	if skeleton_root == null:
		return

	var horizontal_speed := Vector2(
		velocity.x,
		velocity.z
	).length()

	var moving := horizontal_speed > 0.15

	if cast_timer > 0.0:

		animate_cast()

	elif moving:

		var intensity := clamp(
			horizontal_speed / run_speed,
			0.0,
			1.0
		)

		animate_walk(intensity)

	else:

		animate_idle()


func animate_idle() -> void:

	var breathe := sin(animation_time * 2.0) * 0.018

	torso.position.y = 1.48 + breathe

	head.position.y = 2.34 + breathe * 1.3

	arm_l.rotation.z = -0.15
	arm_r.rotation.z = 0.15

	leg_l.rotation.x = 0.0
	leg_r.rotation.x = 0.0

	foot_l.rotation.x = PI / 2.0
	foot_r.rotation.x = PI / 2.0

	staff.rotation.z = -0.04

	if magic_light:
		magic_light.light_energy = 1.4 + sin(animation_time * 4.0) * 0.35

	if staff_crystal:
		var pulse := 1.0 + sin(animation_time * 4.0) * 0.08
		staff_crystal.scale = Vector3(
			0.75 * pulse,
			1.45 * pulse,
			0.75 * pulse
		)


func animate_walk(intensity: float) -> void:

	var frequency := 8.0 + intensity * 2.0
	var phase := animation_time * frequency

	var swing := sin(phase)
	var swing_opposite := sin(phase + PI)

	var leg_amount := 0.48 * intensity
	var arm_amount := 0.34 * intensity

	leg_l.rotation.x = swing * leg_amount
	leg_r.rotation.x = swing_opposite * leg_amount

	arm_l.rotation.x = swing_opposite * arm_amount
	arm_r.rotation.x = swing * arm_amount

	arm_l.rotation.z = -0.15
	arm_r.rotation.z = 0.15

	forearm_l.rotation.x = swing * 0.12
	forearm_r.rotation.x = swing_opposite * 0.12

	hand_l.position.y = 0.79 + swing * 0.04
	hand_r.position.y = 0.79 + swing_opposite * 0.04

	torso.rotation.z = sin(phase * 0.5) * 0.025

	head.rotation.z = sin(phase * 0.5) * 0.015

	robe.rotation.z = sin(phase) * 0.025

	staff.rotation.z = -0.04 + sin(phase) * 0.035

	if magic_light:
		magic_light.light_energy = 1.6 + sin(animation_time * 5.0) * 0.35


func animate_cast() -> void:

	var progress := 1.0 - clamp(
		cast_timer / 0.55,
		0.0,
		1.0
	)

	var wave := sin(progress * PI)

	arm_r.rotation.x = -1.3 * wave
	arm_r.rotation.z = 0.15 + 0.25 * wave

	forearm_r.rotation.x = -1.0 * wave

	hand_r.position.y = 0.82 + 0.35 * wave

	arm_l.rotation.x = -0.5 * wave
	arm_l.rotation.z = -0.15

	head.rotation.x = -0.08 * wave

	if staff:
		staff.rotation.z = -0.04 - 0.2 * wave

	if magic_light:
		magic_light.light_energy = 2.0 + wave * 8.0

	if staff_crystal:
		var scale_power := 1.0 + wave * 0.55

		staff_crystal.scale = Vector3(
			0.75 * scale_power,
			1.45 * scale_power,
			0.75 * scale_power
		)


# ============================================================
# INPUT
# ============================================================

func set_joystick_input(value: Vector2) -> void:
	joystick_input = value


func set_external_input(value: Vector2) -> void:
	external_input = value


# ============================================================
# SPELL
# ============================================================

func cast_spell() -> bool:

	if spell_cooldown > 0.0:
		return false

	if mana < 20:
		return false

	mana -= 20
	spell_cooldown = 0.7
	cast_timer = 0.55

	return true


func restore_mana(amount: int) -> void:
	mana = min(
		mana + amount,
		max_mana
	)


func take_damage(amount: int) -> void:

	hp = max(
		hp - amount,
		0
	)

	if hp <= 0:

		hp = max_hp
		mana = max_mana

		global_position = Vector3(
			0,
			1.2,
			4
		)


func add_xp(amount: int) -> void:

	xp += amount

	var needed := level * 100

	if xp >= needed:

		xp -= needed
		level += 1

		max_hp += 15
		max_mana += 10

		hp = max_hp
		mana = max_mana


# ============================================================
# MESH HELPERS
# ============================================================

func create_capsule(
	node_name: String,
	radius: float,
	height: float,
	material: Material
) -> MeshInstance3D:

	var node := MeshInstance3D.new()
	node.name = node_name

	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mesh.rings = 6

	node.mesh = mesh
	node.material_override = material

	return node


func create_cylinder(
	node_name: String,
	radius: float,
	height: float,
	material: Material
) -> MeshInstance3D:

	var node := MeshInstance3D.new()
	node.name = node_name

	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 20

	node.mesh = mesh
	node.material_override = material

	return node


func create_uv_sphere(
	node_name: String,
	radius: float,
	material: Material
) -> MeshInstance3D:

	var node := MeshInstance3D.new()
	node.name = node_name

	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 24
	mesh.rings = 12

	node.mesh = mesh
	node.material_override = material

	return node


func create_box(
	node_name: String,
	size: Vector3,
	material: Material
) -> MeshInstance3D:

	var node := MeshInstance3D.new()
	node.name = node_name

	var mesh := BoxMesh.new()
	mesh.size = size

	node.mesh = mesh
	node.material_override = material

	return node


func create_torus(
	node_name: String,
	inner_radius: float,
	ring_radius: float,
	material: Material
) -> MeshInstance3D:

	var node := MeshInstance3D.new()
	node.name = node_name

	var mesh := TorusMesh.new()
	mesh.inner_radius = inner_radius
	mesh.outer_radius = inner_radius + ring_radius

	node.mesh = mesh
	node.material_override = material

	return node
