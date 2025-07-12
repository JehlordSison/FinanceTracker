extends Control

@onready var y_axis: VBoxContainer = $"../../../Y-axis"
@onready var x_axis: HBoxContainer = $"../X-axis"
@onready var scroll_container: ScrollContainer = $"../.."

func _process(_delta):
	scroll_container.size.y = y_axis.size.y + x_axis.size.y + 16
