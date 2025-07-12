extends Control

@onready var h_box_container = $ScrollContainer/HBoxContainer
@onready var h_slider = $Zoom/HSlider
@onready var zoom_lbl = $Zoom/ZoomLbl
@onready var zoom = $Zoom

func _ready():
	for i in h_box_container.get_children():
		h_box_container.get_node("Board").connect("graph_edit", graph_edit_visibility)

func graph_edit_visibility(visibility: bool):
	zoom.visible = !visibility

func _on_h_slider_value_changed(value):
	set_zoom(value)
	zoom_lbl.text = str(int(value), "%")
	
func set_zoom(value: int) -> void:
	for i in h_box_container.get_children():
		var line_graph: Control = i.get_node("LineGraph")
		var y_axis: Control = line_graph.get_node("Y-axis")
		
		var separation_percent: float = remap(value, 0, 100, 40, 8)
		var segment_percent: float = remap(value, 0, 100, 5, 10)
		
		y_axis.set("theme_override_constants/separation", separation_percent)
		
		line_graph.y_segment_count = segment_percent
		line_graph.update_table()
		

	
