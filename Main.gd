extends Node3D

# ============================================================
# MAGE RPG - WORLD / GAME MANAGER
# ============================================================

var player: CharacterBody3D

var world_root: Node3D
var environment: WorldEnvironment
var sun: DirectionalLight3D
var moon: DirectionalLight3D

var hud: CanvasLayer
var hp_bar: ProgressBar
var mana_bar: ProgressBar
var xp_bar: ProgressBar

var hp_label: Label
var mana_label: Label
var level_label: Label
var quest_label: Label
var objective_label: Label

var spell_button: Button
var joystick_area: Control

var enemies: Array[Node3D] = []
var npcs: Array[Node3D] = []
var magic_crystals: Array[Node3D] = []

var world_time := 0.0
var quest_started := false
var quest_completed := false

var touch_id := -1
var touch_start := Vector2.ZERO
var joystick_value := Vector2.ZERO

var camera_touch_id := -1
var camera_touch_start := Vector2.ZERO

var random := RandomNumberGenerator.new()


func _ready() -> void:

	random.seed = 872341

	create_world()
	create_player()
	create_npcs()
	create_enemies()
	create_magic_locations()
	create_hud()


func _process(delta: float) -> void:

	world_time += delta

	update_world(delta)
	update_enemies(delta)
	update_hud()

	if player:
		player.set_joystick_input(joystick_value)


# ============================================================
# WORLD
# ============================================================

func create_world() -> void:

	world_root = Node3D.new()
	world_root.name = "FantasyWorld"

	add_child(world_root)

	create_environment()
	create_ground()
	create_water()
	create_hills()
	create_forest()
	create_rocks()
	create_crystals()


func create_environment() -> void:

	environment = WorldEnvironment.new()
	environment.name = "WorldEnvironment"

	var env := Environment.new()

	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(
		0.035,
		0.055,
		0.10
	)

	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(
		0.28,
		0.34,
		0.5
	)

	env.ambient_light_energy = 0.72

	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	env.glow_enabled = true
	env.glow_intensity = 0.85
	env.glow_strength = 1.25

	env.fog_enabled = true
	env.fog_light_color = Color(
		0.11,
		0.15,
		0.22
	)

	env.fog_light_energy = 0.7
	env.fog_density = 0.008
	env.fog_height = 2.0
	env.fog_height_density = 0.015

	environment.environment = env

	add_child(environment)

	sun = DirectionalLight3D.new()
	sun.name = "Sun"

	sun.rotation_degrees = Vector3(
		-48,
		-35,
		0
	)

	sun.light_energy = 1.25
	sun.light_color = Color(
		1.0,
		0.84,
		0.68
	)

	sun.shadow_enabled = true

	add_child(sun)

	moon = DirectionalLight3D.new()
	moon.name = "Moon"

	moon.rotation_degrees = Vector3(
		-25,
		145,
		0
	)

	moon.light_energy = 0.25
	moon.light_color = Color(
		0.25,
		0.4,
		1.0
	)

	moon.shadow_enabled = false

	add_child(moon)


# ============================================================
# GROUND
# ============================================================

func create_ground() -> void:

	var body := StaticBody3D.new()
	body.name = "Ground"

	world_root.add_child(body)

	var collision := CollisionShape3D.new()

	var shape := BoxShape3D.new()
	shape.size = Vector3(
		180,
		2,
		180
	)

	collision.shape = shape
	collision.position.y = -1

	body.add_child(collision)

	var mesh_node := MeshInstance3D.new()
	mesh_node.name = "GroundMesh"

	var mesh := PlaneMesh.new()
	mesh.size = Vector2(
		180,
		180
	)

	mesh.subdivide_width = 30
	mesh.subdivide_depth = 30

	mesh_node.mesh = mesh

	var material := StandardMaterial3D.new()

	material.albedo_color = Color(
		0.075,
		0.19,
		0.09
	)

	material.roughness = 0.98

	mesh_node.material_override = material

	body.add_child(mesh_node)


# ============================================================
# WATER
# ============================================================

func create_water() -> void:

	var water := MeshInstance3D.new()
	water.name = "MoonLake"

	var mesh := PlaneMesh.new()

	mesh.size = Vector2(
		55,
		34
	)

	mesh.subdivide_width = 12
	mesh.subdivide_depth = 12

	water.mesh = mesh
	water.position = Vector3(
		22,
		0.035,
		-24
	)

	var material := StandardMaterial3D.new()

	material.albedo_color = Color(
		0.025,
		0.12,
		0.25,
		0.86
	)

	material.metallic = 0.15
	material.roughness = 0.12

	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	water.material_override = material

	world_root.add_child(water)


# ============================================================
# HILLS
# ============================================================

func create_hills() -> void:

	for i in range(22):

		var hill := MeshInstance3D.new()
		hill.name = "Hill_%02d" % i

		var mesh := SphereMesh.new()

		mesh.radius = random.randf_range(
			4.0,
			8.0
		)

		mesh.height = random.randf_range(
			4.0,
			8.0
		)

		mesh.radial_segments = 20
		mesh.rings = 10

		hill.mesh = mesh

		hill.scale.y = random.randf_range(
			0.45,
			1.15
		)

		hill.position = Vector3(
			random.randf_range(-75, 75),
			-3.0,
			random.randf_range(-75, 75)
		)

		var material := StandardMaterial3D.new()

		material.albedo_color = Color(
			random.randf_range(0.04, 0.08),
			random.randf_range(0.12, 0.2),
			random.randf_range(0.055, 0.1)
		)

		material.roughness = 1.0

		hill.material_override = material

		world_root.add_child(hill)


# ============================================================
# FOREST
# ============================================================

func create_forest() -> void:

	for i in range(85):

		var x := random.randf_range(
			-75,
			75
		)

		var z := random.randf_range(
			-75,
			75
		)

		if Vector2(x, z).distance_to(
			Vector2(0, 0)
		) < 9.0:
			continue

		if z < -7 and x > -5 and x < 48:
			continue

		create_tree(
			Vector3(x, 0, z),
			random.randf_range(
				0.75,
				1.45
			)
		)


func create_tree(
	position: Vector3,
	scale_value: float
) -> void:

	var tree := Node3D.new()
	tree.name = "AncientTree"

	tree.position = position
	tree.scale = Vector3.ONE * scale_value

	world_root.add_child(tree)

	var trunk := MeshInstance3D.new()

	var trunk_mesh := CylinderMesh.new()

	trunk_mesh.top_radius = 0.22
	trunk_mesh.bottom_radius = 0.34
	trunk_mesh.height = 2.9
	trunk_mesh.radial_segments = 10

	trunk.mesh = trunk_mesh

	var bark := StandardMaterial3D.new()

	bark.albedo_color = Color(
		0.12,
		0.055,
		0.028
	)

	bark.roughness = 1.0

	trunk.material_override = bark
	trunk.position.y = 1.45

	tree.add_child(trunk)

	for j in range(3):

		var crown := MeshInstance3D.new()

		var crown_mesh := SphereMesh.new()

		crown_mesh.radius = random.randf_range(
			1.0,
			1.55
		)

		crown_mesh.height = random.randf_range(
			1.6,
			2.3
		)

		crown_mesh.radial_segments = 16
		crown_mesh.rings = 8

		crown.mesh = crown_mesh

		crown.position = Vector3(
			random.randf_range(-0.6, 0.6),
			3.0 + j * 0.35,
			random.randf_range(-0.5, 0.5)
		)

		var leaves := StandardMaterial3D.new()

		leaves.albedo_color = Color(
			0.025,
			random.randf_range(0.12, 0.2),
			0.06
		)

		leaves.roughness = 0.95

		crown.material_override = leaves

		tree.add_child(crown)


# ============================================================
# ROCKS
# ============================================================

func create_rocks() -> void:

	for i in range(65):

		var rock := MeshInstance3D.new()

		var mesh := SphereMesh.new()

		mesh.radius = random.randf_range(
			0.25,
			0.8
		)

		mesh.height = random.randf_range(
			0.35,
			1.2
		)

		mesh.radial_segments = 10
		mesh.rings = 6

		rock.mesh = mesh

		rock.position = Vector3(
			random.randf_range(-75, 75),
			random.randf_range(0.05, 0.35),
			random.randf_range(-75, 75)
		)

		rock.rotation_degrees = Vector3(
			random.randf_range(0, 360),
			random.randf_range(0, 360),
			random.randf_range(0, 360)
		)

		var material := StandardMaterial3D.new()

		material.albedo_color = Color(
			random.randf_range(0.12, 0.2),
			random.randf_range(0.13, 0.19),
			random.randf_range(0.16, 0.22)
		)

		material.roughness = 1.0

		rock.material_override = material

		world_root.add_child(rock)


# ============================================================
# CRYSTALS
# ============================================================

func create_crystals() -> void:

	for i in range(14):

		var crystal := Node3D.new()

		crystal.position = Vector3(
			random.randf_range(-60, 60),
			0,
			random.randf_range(-60, 60)
		)

		world_root.add_child(crystal)

		var mesh_node := MeshInstance3D.new()

		var mesh := PrismMesh.new()

		mesh.size = Vector3(
			0.4,
			random.randf_range(0.8, 1.7),
			0.4
		)

		mesh_node.mesh = mesh

		var material := StandardMaterial3D.new()

		material.albedo_color = Color(
			0.08,
			0.3,
			0.9
		)

		material.emission_enabled = true
		material.emission = Color(
			0.02,
			0.2,
			0.9
		)

		material.emission_energy_multiplier = 3.5

		mesh_node.material_override = material

		mesh_node.position.y = mesh.size.y * 0.5

		crystal.add_child(mesh_node)

		var light := OmniLight3D.new()

		light.light_color = Color(
			0.1,
			0.4,
			1.0
		)

		light.light_energy = 1.8
		light.omni_range = 4.0

		light.position.y = mesh.size.y * 0.5

		crystal.add_child(light)

		magic_crystals.append(crystal)


# ============================================================
# PLAYER
# ============================================================

func create_player() -> void:

	player = preload("res://Player.gd").new()

	player.name = "Mage"

	player.position = Vector3(
		0,
		1.2,
		5
	)

	world_root.add_child(player)


# ============================================================
# NPC
# ============================================================

func create_npcs() -> void:

	var npc := create_npc(
		Vector3(
			-5,
			0,
			-3
		)
	)

	npcs.append(npc)


func create_npc(position: Vector3) -> Node3D:

	var npc := Node3D.new()

	npc.name = "ElderMage"

	npc.position = position

	world_root.add_child(npc)

	var body := MeshInstance3D.new()

	var body_mesh := CapsuleMesh.new()

	body_mesh.radius = 0.35
	body_mesh.height = 1.5

	body.mesh = body_mesh

	var material := StandardMaterial3D.new()

	material.albedo_color = Color(
		0.22,
		0.08,
		0.32
	)

	material.roughness = 0.8

	body.material_override = material

	body.position.y = 0.9

	npc.add_child(body)

	var head := MeshInstance3D.new()

	var head_mesh := SphereMesh.new()

	head_mesh.radius = 0.28
	head_mesh.height = 0.56

	head.mesh = head_mesh

	var skin := StandardMaterial3D.new()

	skin.albedo_color = Color(
		0.62,
		0.38,
		0.28
	)

	head.material_override = skin

	head.position.y = 1.85

	npc.add_child(head)

	var light := OmniLight3D.new()

	light.light_color = Color(
		0.5,
		0.15,
		1.0
	)

	light.light_energy = 1.0
	light.omni_range = 3.0

	light.position.y = 1.6

	npc.add_child(light)

	return npc


# ============================================================
# ENEMIES
# ============================================================

func create_enemies() -> void:

	var positions := [
		Vector3(10, 0, -8),
		Vector3(-14, 0, -12),
		Vector3(17, 0, 9),
		Vector3(-20, 0, 14),
		Vector3(28, 0, -5)
	]

	for pos in positions:

		var enemy := create_enemy(pos)

		enemies.append(enemy)


func create_enemy(position: Vector3) -> Node3D:

	var enemy := Node3D.new()

	enemy.name = "ShadowCreature"

	enemy.position = position

	world_root.add_child(enemy)

	var body := MeshInstance3D.new()

	var body_mesh := CapsuleMesh.new()

	body_mesh.radius = 0.4
	body_mesh.height = 1.25

	body.mesh = body_mesh

	var material := StandardMaterial3D.new()

	material.albedo_color = Color(
		0.09,
		0.015,
		0.12
	)

	material.emission_enabled = true
	material.emission = Color(
		0.15,
		0.01,
		0.18
	)

	material.emission_energy_multiplier = 0.8

	body.material_override = material

	body.position.y = 0.75

	enemy.add_child(body)

	var eye_l := MeshInstance3D.new()

	var eye_mesh := SphereMesh.new()

	eye_mesh.radius = 0.06
	eye_mesh.height = 0.12

	eye_l.mesh = eye_mesh

	var eye_material := StandardMaterial3D.new()

	eye_material.albedo_color = Color(
		1,
		0.05,
		0.03
	)

	eye_material.emission_enabled = true
	eye_material.emission = Color(
		1,
		0.02,
		0
	)

	eye_material.emission_energy_multiplier = 8.0

	eye_l.material_override = eye_material

	eye_l.position = Vector3(
		-0.12,
		1.0,
		0.34
	)

	enemy.add_child(eye_l)

	var eye_r := eye_l.duplicate()

	eye_r.position.x = 0.12

	enemy.add_child(eye_r)

	var light := OmniLight3D.new()

	light.light_color = Color(
		0.8,
		0.03,
		0.02
	)

	light.light_energy = 0.5
	light.omni_range = 2.5

	light.position.y = 1.0

	enemy.add_child(light)

	enemy.add_to_group("enemies")

	return enemy


# ============================================================
# ENEMY AI
# ============================================================

func update_enemies(delta: float) -> void:

	if player == null:
		return

	for enemy in enemies:

		if not is_instance_valid(enemy):
			continue

		var distance := enemy.global_position.distance_to(
			player.global_position
		)

		if distance < 14.0:

			var direction := (
				player.global_position -
				enemy.global_position
			)

			direction.y = 0

			if direction.length_squared() > 0.1:

				direction = direction.normalized()

				enemy.position += direction * delta * 1.25

				var target_rotation := atan2(
					direction.x,
					direction.z
				)

				enemy.rotation.y = lerp_angle(
					enemy.rotation.y,
					target_rotation,
					delta * 4.0
				)

		else:

			enemy.rotation.y += (
				sin(world_time + enemy.get_instance_id()) *
				delta *
				0.2
			)


# ============================================================
# HUD
# ============================================================

func create_hud() -> void:

	hud = CanvasLayer.new()
	hud.name = "HUD"

	add_child(hud)

	# ---------------- TOP LEFT ----------------

	var panel := ColorRect.new()

	panel.position = Vector2(
		24,
		22
	)

	panel.size = Vector2(
		300,
		145
	)

	panel.color = Color(
		0.015,
		0.02,
		0.045,
		0.82
	)

	hud.add_child(panel)

	level_label = create_label(
		"LEVEL 1",
		Vector2(18, 12),
		24
	)

	panel.add_child(level_label)

	hp_label = create_label(
		"HP",
		Vector2(18, 50),
		18
	)

	panel.add_child(hp_label)

	hp_bar = create_progress_bar(
		Vector2(60, 50),
		Vector2(220, 20)
	)

	hp_bar.max_value = 100
	hp_bar.value = 100

	panel.add_child(hp_bar)

	mana_label = create_label(
		"MANA",
		Vector2(18, 82),
		18
	)

	panel.add_child(mana_label)

	mana_bar = create_progress_bar(
		Vector2(60, 82),
		Vector2(220, 20)
	)

	mana_bar.max_value = 100
	mana_bar.value = 100

	panel.add_child(mana_bar)

	xp_bar = create_progress_bar(
		Vector2(18, 116),
		Vector2(262, 14)
	)

	xp_bar.max_value = 100

	panel.add_child(xp_bar)

	# ---------------- QUEST ----------------

	quest_label = create_label(
		"QUEST",
		Vector2(
			24,
			190
		),
		18
	)

	hud.add_child(quest_label)

	objective_label = create_label(
		"Talk to the Elder Mage",
		Vector2(
			24,
			218
		),
		22
	)

	hud.add_child(objective_label)

	# ---------------- SPELL BUTTON ----------------

	spell_button = Button.new()

	spell_button.text = "✦"
	spell_button.position = Vector2(
		1080,
		570
	)

	spell_button.size = Vector2(
		130,
		130
	)

	spell_button.add_theme_font_size_override(
		"font_size",
		46
	)

	spell_button.pressed.connect(
		_on_spell_pressed
	)

	hud.add_child(spell_button)

	# ---------------- JOYSTICK AREA ----------------

	joystick_area = ColorRect.new()

	joystick_area.position = Vector2(
		30,
		520
	)

	joystick_area.size = Vector2(
		260,
		160
	)

	joystick_area.color = Color(
		0.1,
		0.15,
		0.25,
		0.18
	)

	joystick_area.mouse_filter = Control.MOUSE_FILTER_IGNORE

	hud.add_child(joystick_area)


func create_label(
	text_value: String,
	position: Vector2,
	font_size: int
) -> Label:

	var label := Label.new()

	label.text = text_value
	label.position = position

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	return label


func create_progress_bar(
	position: Vector2,
	size: Vector2
) -> ProgressBar:

	var bar := ProgressBar.new()

	bar.position = position
	bar.size = size

	bar.show_percentage = false

	return bar


# ============================================================
# HUD UPDATE
# ============================================================

func update_hud() -> void:

	if player == null:
		return

	if hp_bar:
		hp_bar.value = player.hp

	if mana_bar:
		mana_bar.value = player.mana

	if xp_bar:
		xp_bar.value = player.xp

	if level_label:
		level_label.text = "LEVEL %d" % player.level

	if hp_label:
		hp_label.text = "HP %d / %d" % [
			player.hp,
			player.max_hp
		]

	if mana_label:
		mana_label.text = "MANA %d / %d" % [
			player.mana,
			player.max_mana
		]


# ============================================================
# SPELL
# ============================================================

func _on_spell_pressed() -> void:

	if player == null:
		return

	if player.cast_spell():

		create_spell_projectile()


func create_spell_projectile() -> void:

	var projectile := MeshInstance3D.new()

	var mesh := SphereMesh.new()

	mesh.radius = 0.15
	mesh.height = 0.3

	projectile.mesh = mesh

	var material := StandardMaterial3D.new()

	material.albedo_color = Color(
		0.1,
		0.5,
		1.0
	)

	material.emission_enabled = true

	material.emission = Color(
		0.05,
		0.35,
		1.0
	)

	material.emission_energy_multiplier = 8.0

	projectile.material_override = material

	projectile.global_position = (
		player.global_position +
		Vector3(0, 1.6, 0)
	)

	world_root.add_child(projectile)

	var light := OmniLight3D.new()

	light.light_color = Color(
		0.1,
		0.45,
		1.0
	)

	light.light_energy = 5.0
	light.omni_range = 4.0

	projectile.add_child(light)

	var direction := Vector3(
		sin(player.rotation.y),
		0,
		cos(player.rotation.y)
	)

	projectile.set_meta(
		"velocity",
		direction * 15.0
	)

	projectile.set_meta(
		"life",
		2.0
	)

	projectile.set_process(true)

	var callable := func(delta: float) -> void:

		if not is_instance_valid(projectile):
			return

		var velocity: Vector3 = projectile.get_meta(
			"velocity"
		)

		var life: float = projectile.get_meta(
			"life"
		)

		projectile.position += velocity * delta

		life -= delta

		projectile.set_meta(
			"life",
			life
		)

		if life <= 0.0:
			projectile.queue_free()

	projectile.set_meta(
		"update_callable",
		callable
	)


# ============================================================
# WORLD ANIMATION
# ============================================================

func update_world(delta: float) -> void:

	for crystal in magic_crystals:

		if not is_instance_valid(crystal):
			continue

		crystal.rotation.y += delta * 0.6

		crystal.position.y = (
			sin(
				world_time * 1.5 +
				crystal.get_instance_id()
			) * 0.08
		)

	if sun:

		sun.rotation_degrees.y = (
			-35.0 +
			sin(world_time * 0.015) * 8.0
		)

	if moon:

		moon.rotation_degrees.y = (
			145.0 +
			sin(world_time * 0.012) * 5.0
		)


# ============================================================
# TOUCH INPUT
# ============================================================

func _input(event: InputEvent) -> void:

	if event is InputEventScreenTouch:

		if event.pressed:

			if event.position.x < 450:

				touch_id = event.index
				touch_start = event.position

				joystick_value = Vector2.ZERO

			else:

				camera_touch_id = event.index
				camera_touch_start = event.position

		else:

			if event.index == touch_id:

				touch_id = -1
				joystick_value = Vector2.ZERO

			if event.index == camera_touch_id:

				camera_touch_id = -1

	elif event is InputEventScreenDrag:

		if event.index == touch_id:

			var delta := (
				event.position -
				touch_start
			)

			var radius := 100.0

			joystick_value = (
				delta / radius
			)

			if joystick_value.length() > 1.0:
				joystick_value = joystick_value.normalized()

		elif event.index == camera_
