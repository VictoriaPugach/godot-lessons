extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.coins += 1
		self.queue_free()
		print("Количество собранных монет =", body.coins)
