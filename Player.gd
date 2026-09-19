extends CharacterBody3D

@export var speed: float = 5.0
@export var gravity: float = 12.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3(input.x, 0.0, input.y)

	if direction.length() > 0.0:
		direction = direction.normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	move_and_slide()
