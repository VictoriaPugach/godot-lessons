extends CharacterBody3D

# ПРОСТОЙ скрипт игрока
# Управление: WASD или стрелки - движение, пробел - прыжок

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $CameraPivot/Camera3D

func _ready():
	# Устанавливаем позицию игрока
	global_position = Vector3(0, 1.0, 0)
	velocity = Vector3.ZERO
	
	# Настраиваем камеру
	if camera:
		camera.current = true
		camera.position = Vector3(0, 0.8, 0)
		camera.rotation = Vector3.ZERO
		if $CameraPivot:
			$CameraPivot.position = Vector3.ZERO
			$CameraPivot.rotation = Vector3.ZERO

func _physics_process(delta: float) -> void:
	# Гравитация
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0
	
	# Прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Движение WASD
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
