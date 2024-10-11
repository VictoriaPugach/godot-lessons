extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$hp_bar.max_value = get_node("../Player").health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$hp_bar.value = get_node("../Player").health
