extends Panel
	
@onready var graph_lbl = $GraphLbl
@onready var edit_graph_title = $EditGraphTitle
@onready var line_edit = $EditGraphTitle/LineEdit
signal graph_edit(visibility: bool)

#	EditGraphTitle
func _on_edit_graph_title_visibility_changed():
	emit_signal("graph_edit", edit_graph_title.visible)

#	Buttons
func _on_add_transaction_btn_pressed():
	Instances.add_transcation_panel($"../../../..")

func _on_edit_graph_btn_pressed():
	edit_graph_title.show()

func _on_view_btn_pressed():
	pass

func _on_cancel_btn_pressed():
	edit_graph_title.hide()

func _on_save_btn_pressed():
	graph_lbl.text = line_edit.text
	edit_graph_title.hide()
