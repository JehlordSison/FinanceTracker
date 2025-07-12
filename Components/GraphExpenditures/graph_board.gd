extends Panel
	
var default_size: Vector2

func _ready():
	default_size = size

func _on_full_screen_btn_pressed():
	if size == default_size:
		size = get_viewport_rect().size
	else:
		size = default_size

func _on_add_transaction_btn_pressed():
	Instances.add_transcation_panel($"../../../..")
