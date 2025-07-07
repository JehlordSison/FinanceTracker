extends Control

var RECORDS: Dictionary = {
	"06/30/2025": { 
		"10:51:15 PM": 1.0
	},
	"01/15/2024": {
		"08:30:00 AM": 3.0
	},
	"03/01/2025": {
		"02:06:30 PM": 1.0, 
		"02:00:00 PM": 4.0,
		"02:05:30 PM": 6.0
	},
	"07/22/2024": {
		"09:15:40 AM": 5.0
	},
	"11/05/2025": {
		"04:45:00 PM": 200.00
	},
	"02/10/2024": {
		"07:00:00 AM": 56.0
	},
	"09/18/2025": {
		"01:10:20 AM": 410.0
	},
	"04/03/2024": {
		"11:59:59 PM": 500.00
	},
	"10/30/2024": {
		"06:00:00 PM": 1334.00
	},
	"05/01/2025": {
		"12:00:00 AM": 150.00
	},
	"08/08/2024": {
		"03:30:10 PM": 250.70
	}
}

@onready var y_axis = $"HSplitContainer/Y-axis"
@onready var x_axis = $"HSplitContainer/ScrollContainer/VSplitContainer/X-axis"

@export_category("Y-Axis Settings")
@export var y_segment_count: int = 5

func _ready():
	sort_transactions()
	set_axis()

func sort_transactions() -> void:
	"
		Dictionary 'MUST' Follow a format:
		var DICTIONARY = { DATE: {TIME: AMOUNT,}, }
	"
	#	Sort time in each transactions
	var new_record: Dictionary = RECORDS
	for date in new_record:
		new_record[date].sort()
	new_record.sort()
	RECORDS = new_record

func set_axis() -> void:
	#	Storages
	var amount_list: Array = []
	var segments: Array = []
	
	#	Get all amount from Records
	for amount in RECORDS.values():
		for i in amount.values():
			amount_list.append(i)
		amount_list.sort()
		amount_list.reverse()
	
	#	Create Segments out of highest amount
	var max_amount: float = amount_list.max()
	var ceiling: float = round_up_to_nice_number(max_amount)	#	Ceiling
	var step: float = ceiling / y_segment_count
	for i in range(int(y_segment_count) + 1):
		segments.append(ceiling - (i * step))
		segments.sort()
		segments.reverse()
	
	#	Y-Axis
	for i in segments:
		var label: Label = Label.new()
		label.text = str(i)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		y_axis.add_child(label)
	
	#	X-Axis
	for date in RECORDS:
		var label: Label = Label.new()
		label.text = date
		x_axis.add_child(label)
	
func round_up_to_nice_number(value: float) -> float:
	if value <= 0:
		return 0
	
	# Find the magnitude (power of 10)
	var magnitude = pow(10, floor(log(value) / log(10)))
	
	# Common nice intervals based on magnitude
	var intervals = [magnitude, magnitude * 2, magnitude * 5]
	
	# Find the smallest interval that's >= value
	for interval in intervals:
		if interval >= value:
			return interval
	
	# If none work, use the next magnitude
	return magnitude * 10
