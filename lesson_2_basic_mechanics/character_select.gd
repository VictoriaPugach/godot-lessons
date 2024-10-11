extends Node2D

func _process(delta: float) -> void:
	match Game.PlayerSelect:
		0:
			get_node("PlayerSelect").play("Player0")
		1:
			get_node("PlayerSelect").play("Player1")
		2:
			get_node("PlayerSelect").play("Player2")
		3:
			get_node("PlayerSelect").play("Player3")


func _on_left_pressed() -> void:
	if Game.PlayerSelect > 0:
		Game.PlayerSelect -= 1

func _on_right_pressed() -> void:
	if Game.PlayerSelect < 4: # так как у меня 4 персонажа
		Game.PlayerSelect += 1
		
func _on_select_pressed() -> void:
	get_tree().change_scene_to_file("res://my_game.tscn")
