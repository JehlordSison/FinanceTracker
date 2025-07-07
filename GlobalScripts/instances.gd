extends Node

@onready var transaction_panel: PackedScene = preload("res://Components/Transaction/add_transaction_panel.tscn")

func add_transcation_panel(obj: Control) -> void:
	var node: Control = transaction_panel.instantiate()
	obj.add_child(node)
	
