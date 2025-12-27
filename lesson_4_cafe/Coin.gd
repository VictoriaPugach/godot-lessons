extends Area3D

# Скрипт монетки для сбора
# Когда игрок касается монетки, она собирается

@export var coin_value: int = 1

var collected: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if not collected and body.name == "Player":
		collect()

func collect():
	collected = true
	Game.add_coins(coin_value)
	Game.show_message.emit("Собрана монетка! Монет: " + str(Game.get_coins()))
	# Анимация исчезновения
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(queue_free)
