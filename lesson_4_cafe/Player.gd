extends CharacterBody3D

# Скрипт игрока для first-person камеры (вид от первого лица)
# Управление: WASD - движение, мышь - поворот камеры, стрелки - движение и поворот

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003

# Получаем гравитацию из настроек проекта
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Ссылка на камеру (будет установлена в _ready)
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

func _ready():
	# Блокируем курсор мыши в центре экрана
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Проверяем, есть ли камера, если нет - создаём её
	if not has_node("CameraPivot"):
		var pivot = Node3D.new()
		pivot.name = "CameraPivot"
		add_child(pivot)
		camera_pivot = pivot
		
		var cam = Camera3D.new()
		cam.name = "Camera3D"
		cam.current = true
		cam.position = Vector3(0, 1.6, 0)  # Высота глаз
		pivot.add_child(cam)
		camera = cam
	else:
		# Если камера уже есть, получаем ссылки
		camera_pivot = get_node("CameraPivot")
		if camera_pivot.has_node("Camera3D"):
			camera = camera_pivot.get_node("Camera3D")
			camera.current = true

func _input(event):
	# Обработка движения мыши для поворота камеры
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Поворачиваем игрока по Y (горизонтально)
		rotate_y(-event.relative.x * mouse_sensitivity)
		# Поворачиваем камеру по X (вертикально)
		if camera_pivot:
			camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
			# Ограничиваем вертикальный угол (чтобы не перевернуть камеру)
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -1.5, 1.5)
	
	# Escape для освобождения курсора
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Добавляем гравитацию
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Получаем направление ввода (WASD или стрелки)
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Преобразуем направление ввода в направление движения относительно камеры
	# Берем горизонтальную плоскость направления взгляда игрока
	var direction := Vector3.ZERO
	if input_dir.length() > 0:
		# Получаем направление вперед и вправо от игрока (повернутого по Y)
		# В Godot для CharacterBody3D transform.basis.z указывает вперед
		var forward = transform.basis.z   # Направление вперед (куда смотрит игрок)
		var right = transform.basis.x     # Направление вправо
		
		# Объединяем направления в зависимости от ввода
		# input_dir.y: положительный = стрелка вверх = вперед
		# input_dir.x: положительный = стрелка вправо = вправо
		direction = (forward * input_dir.y + right * input_dir.x).normalized()
	
	# Применяем движение
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		# Плавная остановка
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
