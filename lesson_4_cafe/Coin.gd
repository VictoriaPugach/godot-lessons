extends Area3D

# Скрипт монетки для сбора
# Когда игрок касается монетки, она собирается

@export var coin_value: int = 1

var collected: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	print("Монетка готова, позиция: ", global_position)

func _on_body_entered(body: Node3D):
	# Проверяем, что это CharacterBody3D (игрок)
	if not collected and body is CharacterBody3D:
		print("Игрок вошел в зону монетки! Позиция игрока: ", body.global_position, ", монетки: ", global_position)
		collect()

func collect():
	if collected:
		return  # Уже собрана
	collected = true
	print("Собираю монетку! Значение: ", coin_value)
	Game.add_coins(coin_value)
	Game.show_message.emit("Собрана монетка! Монет: " + str(Game.get_coins()))
	# Анимация исчезновения
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(queue_free)
