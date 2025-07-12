extends Control

@onready var h_box_container = $ScrollContainer/HBoxContainer
@onready var zoom_lbl = $ZoomLbl

func _on_h_slider_value_changed(value):
	set_zoom(value)
	zoom_lbl.text = str(int(value), "%")
	
func set_zoom(value: int) -> void:
	for i in h_box_container.get_children():
		var line_graph: Control = i.get_node("LineGraph")
		var y_axis: Control = line_graph.get_node("Y-axis")
		var x_axis: Control = line_graph.get_node("ScrollContainer/VSplitContainer/X-axis")
		
		var separation_percent: float = remap(value, 0, 100, 40, 8)
		var segment_percent: float = remap(value, 0, 100, 5, 10)
		
		for y in y_axis.get_children():
			y.queue_free()
		for x in x_axis.get_children():
			x.queue_free()
			
		y_axis.set("theme_override_constants/separation", separation_percent)
		
		line_graph.y_segment_count = segment_percent
		line_graph.set_axis()
		line_graph.update_plotted_coordinates()
		#	15 min 40 max for separation - 5 min 10 max for segments
	

	
