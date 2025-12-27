extends CanvasLayer

# Скрипт для управления UI (счетчик монет и сообщения)

@onready var coin_panel: Panel
@onready var coin_label: Label
@onready var message_panel: Panel
@onready var message_label: Label

func _ready():
	# Удаляем старые UI элементы если есть
	_remove_old_ui()
	
	# Создаем новые UI элементы
	_create_ui()
	
	Game.coins_changed.connect(_on_coins_changed)
	Game.show_message.connect(_on_show_message)
	call_deferred("_update_coin_display")
	print("UIManager готов. Сигналы подключены.")

func _remove_old_ui():
	# Удаляем старый VBoxContainer если он есть
	var old_container = get_node_or_null("Control/VBoxContainer")
	if old_container:
		old_container.queue_free()

func _create_ui():
	var control = get_node_or_null("Control")
	if not control:
		var new_control = Control.new()
		new_control.name = "Control"
		new_control.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(new_control)
		control = new_control
	
	# Создаем панель для монет (верхний левый угол)
	var panel = Panel.new()
	panel.name = "CoinPanel"
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(20, 20)
	panel.size = Vector2(200, 50)
	
	# Добавляем стиль к панели
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_right = 10
	style_box.corner_radius_bottom_left = 10
	panel.add_theme_stylebox_override("panel", style_box)
	
	var label = Label.new()
	label.name = "CoinLabel"
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1, 0.84, 0))  # Золотой цвет
	label.text = "💰 Монет: 0"
	panel.add_child(label)
	control.add_child(panel)
	coin_panel = panel
	coin_label = label
	
	# Создаем панель для сообщений (внизу по центру)
	var msg_panel = Panel.new()
	msg_panel.name = "MessagePanel"
	msg_panel.anchor_left = 0.5
	msg_panel.anchor_top = 1.0
	msg_panel.anchor_right = 0.5
	msg_panel.anchor_bottom = 1.0
	msg_panel.offset_left = -300
	msg_panel.offset_top = -50
	msg_panel.offset_right = 300
	msg_panel.offset_bottom = 0
	# grow_direction настраивается автоматически через anchors
	
	var msg_style_box = StyleBoxFlat.new()
	msg_style_box.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	msg_style_box.corner_radius_top_left = 15
	msg_style_box.corner_radius_top_right = 15
	msg_style_box.corner_radius_bottom_right = 0
	msg_style_box.corner_radius_bottom_left = 0
	msg_panel.add_theme_stylebox_override("panel", msg_style_box)
	
	var msg_label = Label.new()
	msg_label.name = "MessageLabel"
	msg_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	msg_label.add_theme_font_size_override("font_size", 20)
	msg_label.add_theme_color_override("font_color", Color(1, 1, 1))
	msg_label.text = ""
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_panel.add_child(msg_label)
	msg_panel.visible = false
	control.add_child(msg_panel)
	message_panel = msg_panel
	message_label = msg_label

func _on_coins_changed(new_amount: int):
	_update_coin_display()

func _update_coin_display():
	if coin_label:
		coin_label.text = "💰 Монет: " + str(Game.get_coins())

func _on_show_message(message: String):
	if message_label and message_panel:
		message_label.text = message
		message_panel.visible = true
		
		# Сообщение исчезает через 4 секунды
		var timer = get_tree().create_timer(4.0)
		timer.timeout.connect(func(): 
			if message_label and message_panel:
				message_label.text = ""
				message_panel.visible = false
		)
