extends Area3D

# Скрипт еды на прилавке
# Можно купить за монетки
# Поддерживает разные модели (пончики, бургер, торт)

@export var food_name: String = "Бургер"  # Название еды (будет показано на ценнике и при покупке)
@export var price: int = 5
@export var food_description: String = "Вкусный бургер"  # Описание (необязательно)

var player_near: bool = false
var is_purchased: bool = false
var price_label: Label3D = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Автоматически назначаем цены по названию
	# Если цена не задана явно (осталась 5), назначаем автоматически
	if price == 5:
		_assign_price_by_name()
	
	# Создаем ценник над едой
	_create_price_label()
	
	print("Food готов: ", food_name, " (цена: ", price, ")")

func _assign_price_by_name():
	# Назначаем цены в зависимости от названия
	match food_name:
		"Бургер":
			price = 1
		"Пончики", "Пончик", "Donut":
			price = 2
		"Торт", "Cake":
			price = 3
		"Пицца":
			price = 2
		"Напиток":
			price = 3
		_:
			price = 2  # Дефолтная цена для неизвестных названий

func _create_price_label():
	# Создаем Label3D для отображения цены и названия
	price_label = Label3D.new()
	price_label.name = "PriceLabel"
	price_label.text = food_name + "\n" + str(price) + " монет"
	price_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	price_label.no_depth_test = true
	price_label.pixel_size = 0.01
	price_label.font_size = 18
	price_label.modulate = Color(1, 1, 0.5)  # Желтоватый цвет
	
	# Позиционируем над едой (ищем модель или используем стандартную позицию)
	var mesh_instance = get_node_or_null("MeshInstance3D")
	var model_node = null
	
	# Пытаемся найти дочерний узел с моделью (GLB инстанс)
	for child in get_children():
		if child is Node3D and child != price_label:
			model_node = child
			break
	
	if model_node:
		# Если есть модель, позиционируем ценник повыше
		price_label.position = Vector3(0, 0.6, 0)
	elif mesh_instance:
		price_label.position = Vector3(0, 0.5, 0)
	else:
		price_label.position = Vector3(0, 0.3, 0)
	
	add_child(price_label)

func _on_body_entered(body: Node3D):
	# Проверяем, что это CharacterBody3D (игрок)
	if body is CharacterBody3D:
		print("Игрок вошел в зону еды: ", food_name)
		if not is_purchased:
			player_near = true
			Game.show_message.emit("Нажмите E чтобы купить " + food_name + " за " + str(price) + " монет")
			# Подсвечиваем ценник
			if price_label:
				price_label.modulate = Color(0.5, 1, 0.5)  # Зеленоватый цвет

func _on_body_exited(body: Node3D):
	# Проверяем, что это CharacterBody3D (игрок)
	if body is CharacterBody3D:
		print("Игрок вышел из зоны еды: ", food_name)
		player_near = false
		# Возвращаем обычный цвет ценнику
		if price_label and not is_purchased:
			price_label.modulate = Color(1, 1, 0.5)

func _process(_delta):
	# Проверяем ввод в _process вместо _input для более надежной работы
	if player_near and not is_purchased:
		if Input.is_action_just_pressed("interact"):
			print("Нажата клавиша E для покупки: ", food_name)
			buy_food()

func buy_food():
	print("Попытка купить: ", food_name, ", цена: ", price, ", монет: ", Game.get_coins())
	if Game.spend_coins(price):
		is_purchased = true
		Game.show_message.emit("✅ Вы купили " + food_name + "! Осталось монет: " + str(Game.get_coins()))
		print("Покупка успешна!")
		# Меняем ценник на "куплено"
		if price_label:
			price_label.text = "✅ " + food_name + "\nКуплено!"
			price_label.modulate = Color(0.5, 1, 0.5)
		# Визуальная обратная связь - немного поднимаем еду
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector3(0, 0.2, 0), 0.3)
	else:
		Game.show_message.emit("❌ Недостаточно монет! Нужно " + str(price) + " 💰, у вас " + str(Game.get_coins()))
		print("Недостаточно монет!")
