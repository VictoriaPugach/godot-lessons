extends Area3D

# Скрипт кассира для диалога
# Когда игрок подходит близко, можно поговорить
# Поддерживает анимированные модели (стоять и махать)

@export var dialog_text: String = "Добро пожаловать в наше кафе!"

# Имена анимаций (настройте под вашу модель)
@export var idle_animation: String = "Take 001"  # Анимация покоя (стоять) - используем "Take 001" из модели
@export var wave_animation: String = "Take 001"  # Анимация махания - используем "Take 001" из модели
@export var talk_animation: String = "Take 001"  # Анимация разговора (необязательно)

var player_near: bool = false
var player: Node3D = null
var animation_player: AnimationPlayer = null
var current_animation_name: String = ""

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("Кассир готов, позиция: ", global_position)
	
	# Ищем AnimationPlayer в дочерних узлах (рекурсивно)
	_find_animation_player(self)
	
	# Если нашли AnimationPlayer, запускаем idle анимацию (стоять) с зацикливанием
	if animation_player:
		var anims = animation_player.get_animation_list()
		print("AnimationPlayer найден! Доступные анимации: ", anims)
		
		# Пробуем найти подходящую анимацию и зациклить её
		if animation_player.has_animation(idle_animation):
			_play_animation_looped(idle_animation)
		elif animation_player.has_animation(wave_animation):
			_play_animation_looped(wave_animation)
		elif anims.size() > 0:
			# Играем первую доступную анимацию с зацикливанием
			_play_animation_looped(anims[0])
	else:
		print("⚠️ AnimationPlayer не найден - модель не анимированная или использует другой способ анимации")

func _find_animation_player(node: Node):
	# Рекурсивно ищем AnimationPlayer во всех дочерних узлах
	if node is AnimationPlayer:
		animation_player = node
		return
	
	for child in node.get_children():
		_find_animation_player(child)
		if animation_player:
			return

func _play_animation_looped(anim_name: String):
	# Проигрывает анимацию с зацикливанием
	if animation_player and animation_player.has_animation(anim_name):
		var anim = animation_player.get_animation(anim_name)
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR  # Зацикливание
		# Проигрываем анимацию (зацикливание установлено через loop_mode)
		animation_player.play(anim_name)
		current_animation_name = anim_name
		print("Воспроизводится анимация (зациклена): ", anim_name)

func _on_body_entered(body: Node3D):
	# Проверяем, что это CharacterBody3D (игрок)
	if body is CharacterBody3D:
		print("Игрок вошел в зону кассира! Позиция игрока: ", body.global_position, ", кассира: ", global_position)
		player_near = true
		player = body
		
		Game.show_message.emit("Нажмите E для разговора с кассиром")
		print("Сообщение отправлено, игрок рядом: ", player_near)
		
		# Проигрываем анимацию махания (greeting) с зацикливанием
		if animation_player:
			if animation_player.has_animation(wave_animation):
				_play_animation_looped(wave_animation)
			elif animation_player.has_animation(idle_animation):
				_play_animation_looped(idle_animation)

func _on_body_exited(body: Node3D):
	# Проверяем, что это CharacterBody3D (игрок)
	if body is CharacterBody3D:
		print("Игрок вышел из зоны кассира")
		player_near = false
		player = null
		
		# Возвращаемся к анимации покоя (стоять) с зацикливанием
		if animation_player:
			if animation_player.has_animation(idle_animation):
				_play_animation_looped(idle_animation)

func _process(_delta):
	# Проверяем ввод в _process вместо _input для более надежной работы
	if player_near:
		if Input.is_action_just_pressed("interact"):  # E key
			print("Нажата клавиша E для разговора с кассиром")
			show_dialog()

func show_dialog():
	var dialog = "💬 Кассир: " + dialog_text
	Game.show_message.emit(dialog)
	print("Кассир говорит: ", dialog_text)
	
	# Проигрываем анимацию разговора (если есть)
	if animation_player:
		if animation_player.has_animation(talk_animation):
			var anim = animation_player.get_animation(talk_animation)
			if anim:
				anim.loop_mode = Animation.LOOP_LINEAR
			animation_player.play(talk_animation)
			current_animation_name = talk_animation
			# После окончания анимации возвращаемся к idle
			if animation_player.has_animation(idle_animation):
				await get_tree().create_timer(anim.length).timeout
				if current_animation_name == talk_animation:
					_play_animation_looped(idle_animation)
