extends Panel
	
@onready var graph_lbl = $GraphLbl
@onready var edit_graph = $EditGraph
@onready var line_edit = $EditGraph/LineEdit
signal graph_edit(visibility: bool)

#	EditGraphTitle
func _on_edit_graph_visibility_changed():
	await get_tree().physics_frame
	emit_signal("graph_edit", edit_graph.visible)

#	Buttons
func _on_add_transaction_btn_pressed():
	Instances.add_transcation_panel($"../../../..")

func _on_edit_graph_btn_pressed():
	edit_graph.show()

func _on_view_btn_pressed():
	pass

func _on_cancel_btn_pressed():
	edit_graph.hide()

func _on_save_btn_pressed():
	graph_lbl.text = line_edit.text
	edit_graph.hide()
