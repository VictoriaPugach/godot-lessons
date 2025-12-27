extends Area3D

# Скрипт кассира для диалога
# Когда игрок подходит близко, можно поговорить

@export var dialog_text: String = "Добро пожаловать в наше кафе! Нажмите E, чтобы поговорить."

var player_near: bool = false
var player: Node3D = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("Кассир готов")

func _on_body_entered(body: Node3D):
	# Проверяем, что это CharacterBody3D (игрок)
	if body is CharacterBody3D:
		print("Игрок вошел в зону кассира")
		player_near = true
		player = body
		Game.show_message.emit("Нажмите E для разговора с кассиром")
		print("Сообщение отправлено, игрок рядом: ", player_near)

func _on_body_exited(body: Node3D):
	# Проверяем, что это CharacterBody3D (игрок)
	if body is CharacterBody3D:
		print("Игрок вышел из зоны кассира")
		player_near = false
		player = null

func _process(_delta):
	# Проверяем ввод в _process вместо _input для более надежной работы
	if player_near:
		if Input.is_action_just_pressed("interact"):  # E key
			print("Нажата клавиша E для разговора с кассиром")
			show_dialog()

func show_dialog():
	var dialog = dialog_text
	Game.show_message.emit(dialog)
	print("Кассир говорит: ", dialog)
