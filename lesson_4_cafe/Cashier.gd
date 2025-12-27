extends Area3D

# Скрипт кассира для диалога
# Когда игрок подходит близко, можно поговорить

@export var dialog_text: String = "Добро пожаловать в наше кафе! Нажмите E, чтобы поговорить."

var player_near: bool = false
var player: Node3D = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	if body.name == "Player":
		player_near = true
		player = body
		Game.show_message.emit("Подойдите ближе к кассиру и нажмите E для разговора")

func _on_body_exited(body: Node3D):
	if body.name == "Player":
		player_near = false
		player = null

func _process(_delta):
	# Проверяем ввод в _process вместо _input для более надежной работы
	if player_near and Input.is_action_just_pressed("interact"):  # E key
		show_dialog()

func show_dialog():
	var dialog = dialog_text
	Game.show_message.emit(dialog)
	print("Кассир: ", dialog)
