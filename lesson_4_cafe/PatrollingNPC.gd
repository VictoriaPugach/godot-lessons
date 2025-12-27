extends Node3D

# Простой скрипт для патрулирующего NPC (женщина ходит по магазину)
# Модель должна иметь анимацию ходьбы

@export var walk_animation: String = "Take 001"  # Имя анимации ходьбы - используем "Take 001" из модели
@export var patrol_distance: float = 5.0  # Расстояние патрулирования
@export var patrol_speed: float = 1.5  # Скорость движения (метры в секунду)

var animation_player: AnimationPlayer = null
var model_root: Node3D = null
var start_position: Vector3
var patrol_direction: int = 1
var movement_tween: Tween = null
var current_animation_name: String = ""

func _ready():
	start_position = global_position
	
	# Ищем AnimationPlayer и корневой узел модели
	_find_model_components(self)
	
	print("PatrollingNPC готов. Позиция: ", global_position)
	
	if animation_player:
		var anims = animation_player.get_animation_list()
		print("AnimationPlayer найден! Доступные анимации: ", anims)
	else:
		print("⚠️ AnimationPlayer не найден - проверьте структуру модели")
	
	# Запускаем патрулирование
	_start_patrol()

func _find_model_components(node: Node):
	# Рекурсивно ищем AnimationPlayer и корневой узел модели
	if node is AnimationPlayer:
		animation_player = node
		return
	
	# Первый Node3D который является прямым потомком - это корень модели
	if node is Node3D and node != self and node.get_parent() == self:
		if model_root == null:
			model_root = node
	
	for child in node.get_children():
		_find_model_components(child)
		if animation_player:
			return

func _play_walk_animation():
	# Проигрываем анимацию ходьбы с зацикливанием
	if animation_player:
		# Пробуем разные варианты имен анимаций
		var animation_names = [walk_animation, "Walk", "Walking", "Run", "Running", "basic walk", "Take 001"]
		var found_anim = false
		
		for anim_name in animation_names:
			if animation_player.has_animation(anim_name):
				# Получаем анимацию и устанавливаем зацикливание
				var anim = animation_player.get_animation(anim_name)
				if anim:
					# Устанавливаем зацикливание
					anim.loop_mode = Animation.LOOP_LINEAR
					# Также устанавливаем в AnimationPlayer
					animation_player.set_assigned_animation(anim_name)
				
				# Проигрываем анимацию (зацикливание установлено через loop_mode)
				animation_player.play(anim_name)
				current_animation_name = anim_name
				print("Воспроизводится анимация ходьбы (зациклена): ", anim_name)
				found_anim = true
				break
		
		if not found_anim:
			# Пробуем первую доступную анимацию
			var anims = animation_player.get_animation_list()
			if anims.size() > 0:
				var anim_name = anims[0]
				var anim = animation_player.get_animation(anim_name)
				if anim:
					anim.loop_mode = Animation.LOOP_LINEAR
				animation_player.play(anim_name)
				current_animation_name = anim_name
				print("Воспроизводится первая доступная анимация (зациклена): ", anim_name)

func _start_patrol():
	# Вычисляем целевую позицию
	var target_offset = Vector3(0, 0, patrol_distance * patrol_direction)
	var target_position = start_position + target_offset
	
	# Вычисляем время движения
	var distance = global_position.distance_to(target_position)
	var duration = distance / patrol_speed if patrol_speed > 0 else 1.0
	
	# Проигрываем анимацию ходьбы (зацикленную)
	_play_walk_animation()
	
	# Поворачиваем модель в направлении движения
	if model_root:
		var direction = (target_position - global_position).normalized()
		if direction.length() > 0.1:
			var angle = atan2(direction.x, direction.z)
			model_root.rotation.y = angle
	
	# Создаем Tween для плавного движения
	if movement_tween:
		movement_tween.kill()
	
	movement_tween = create_tween()
	movement_tween.tween_property(self, "global_position", target_position, duration)
	movement_tween.tween_callback(_on_patrol_reached_target)

func _on_patrol_reached_target():
	# Меняем направление
	patrol_direction *= -1
	
	# Небольшая пауза перед поворотом
	await get_tree().create_timer(0.3).timeout
	
	# Продолжаем патрулирование (анимация уже зациклена, просто продолжаем движение)
	_start_patrol()
