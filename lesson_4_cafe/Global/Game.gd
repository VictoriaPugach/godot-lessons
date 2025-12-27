extends Node

# Глобальный скрипт для управления игрой
# Управляет монетками и UI

signal coins_changed(new_amount)
signal show_message(message)

var coins: int = 0

func add_coins(amount: int):
	coins += amount
	coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		coins_changed.emit(coins)
		return true
	return false

func get_coins() -> int:
	return coins

