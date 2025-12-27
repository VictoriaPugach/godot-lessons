extends CanvasLayer

# Скрипт для управления UI (счетчик монет и сообщения)
# ВАЖНО: Структура UI должна быть создана в редакторе согласно инструкциям!

@onready var coin_label: Label = $Control/VBoxContainer/CoinLabel
@onready var message_label: Label = $Control/VBoxContainer/MessageLabel

func _ready():
	Game.coins_changed.connect(_on_coins_changed)
	Game.show_message.connect(_on_show_message)
	# Ждем один кадр, чтобы UI узлы точно были созданы
	call_deferred("_update_coin_display")

func _on_coins_changed(new_amount: int):
	_update_coin_display()

func _update_coin_display():
	if coin_label:
		coin_label.text = "Монет: " + str(Game.get_coins())
	else:
		print("CoinLabel не найден! Проверьте структуру UI в сцене.")

func _on_show_message(message: String):
	if message_label:
		message_label.text = message
		# Сообщение исчезает через 3 секунды
		var timer = get_tree().create_timer(3.0)
		timer.timeout.connect(func(): 
			if message_label:
				message_label.text = ""
		)
	else:
		print("MessageLabel не найден! Проверьте структуру UI в сцене.")
		print("Сообщение: ", message)
