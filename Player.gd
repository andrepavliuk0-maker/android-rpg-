extends CharacterBody3D

@export var move_speed: float = 5.0
@export var gravity: float = 18.0
@export var rotation_speed: float = 10.0
@export var max_hp: int = 100
@export var max_mana: int = 100

var hp: int = 100
var mana: int = 100

var joystick_input := Vector2.ZERO
var camera: Camera3D
var spell_cooldown := 0.0

func _ready() -> void:
	hp = max_hp
	mana = max_mana
	camera = get_node_or_null("Camera3D")


func _physics_process(delta: float) -> void:
	if spell_cooldown > 0.0:
		spell_cooldown -= delta

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var input_vector := joystick_input

	if input_vector.length_squared() < 0.01:
		input_vector = Input.get_vector(
			"ui_left",
			"ui_right",
			"ui_up",
			"ui_down"
		)

	var direction := Vector3(
		input_vector.x,
		0.0,
		input_vector.y
	)

	if direction.length_squared() > 0.01:
		direction = direction.normalized()

		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed

		var target_rotation := atan2(direction.x, direction.z)

		rotation.y = lerp_angle(
			rotation.y,
			target_rotation,
			rotation_speed * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			move_speed * 8.0 * delta
		)

		velocity.z = move_toward(
			velocity.z,
			0.0,
			move_speed * 8.0 * delta
		)

	move_and_slide()


func set_joystick_input(value: Vector2) -> void:
	joystick_input = value


func cast_spell() -> bool:
	if spell_cooldown > 0.0:
		return false

	if mana < 20:
		return false

	mana -= 20
	spell_cooldown = 0.7

	return true


func restore_mana(amount: int) -> void:
	mana = min(mana + amount, max_mana)


func take_damage(amount: int) -> void:
	hp = max(hp - amount, 0)

	if hp <= 0:
		hp = max_hp
		mana = max_mana
		global_position = Vector3(0, 1.2, 5)
