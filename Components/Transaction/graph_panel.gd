extends Panel

@onready var profit_icon = $ProfitIcon
@onready var loss_icon = $LossIcon
@onready var status_option_btn = $"../StatusOptionBtn"
@onready var description_lbl = $DescriptionLbl

func _ready():
	status_option_btn.emit_signal("item_selected", 0)

func _on_status_option_btn_item_selected(index):
	match index:
		0:
			description_lbl.text = "income is going up"
			profit_icon.show()
			loss_icon.hide()
		1: 
			description_lbl.text = "income went down"
			profit_icon.hide()
			loss_icon.show()
	pass # Replace with function body.
