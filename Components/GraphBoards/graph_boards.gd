extends Control

@onready var h_box_container = $ScrollContainer/HBoxContainer

func set_zoom(value: int) -> void:
	for i in h_box_container.get_children():
		var line_graph: Control = i.get_node("LineGraph")
		var y_axis: Control = line_graph.get_node("HSplitContainer/Y-axis")
		#	Update
		y_axis.set("theme_override_constants/separation", value)
		line_graph.update_plotted_coordinates()
		
func _on_h_slider_value_changed(value):
	set_zoom(value)
