extends Area3D

# Скрипт еды на прилавке
# Можно купить за монетки

@export var food_name: String = "Бургер"
@export var price: int = 5
@export var food_description: String = "Вкусный бургер"

var player_near: bool = false
var is_purchased: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	if not is_purchased and body.name == "Player":
		player_near = true
		Game.show_message.emit("Нажмите E чтобы купить " + food_name + " за " + str(price) + " монет")

func _on_body_exited(body: Node3D):
	if body.name == "Player":
		player_near = false

func _process(_delta):
	# Проверяем ввод в _process вместо _input для более надежной работы
	if player_near and not is_purchased and Input.is_action_just_pressed("interact"):
		buy_food()

func buy_food():
	if Game.spend_coins(price):
		is_purchased = true
		Game.show_message.emit("Вы купили " + food_name + "! Осталось монет: " + str(Game.get_coins()))
		# Визуальная обратная связь - немного поднимаем еду
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector3(0, 0.2, 0), 0.3)
	else:
		Game.show_message.emit("Недостаточно монет! Нужно " + str(price) + ", у вас " + str(Game.get_coins()))
