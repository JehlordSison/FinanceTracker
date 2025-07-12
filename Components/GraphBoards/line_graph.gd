extends Control

var RECORDS: Dictionary = {
	"06/30/2025": { 
		"10:51:15 PM": 500
	},
	"01/15/2024": {
		"08:30:00 AM": 3000
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
		"01:10:20 AM": 4010.0
	},
	"04/03/2024": {
		"11:59:59 PM": 500.00
	},
	"10/30/2024": {
		"06:00:00 PM": 5334.00
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
@onready var line: Control = $HSplitContainer/ScrollContainer/VSplitContainer/Line

@export_category("Y-Axis Settings")
@export var y_segment_count: int = 5

func _ready():
	sort_transactions()
	set_axis()
	
func set_grid() -> void:
	await get_tree().process_frame
	#	Y-Axis
	var g_size: int
	for i in y_axis.get_children():
		var grid_x: Line2D = Line2D.new()
		grid_x.add_point(Vector2(2,i.position.y + (i.size.y/2)))
		grid_x.add_point(Vector2(line.size.x,  i.position.y + (i.size.y/2)))
		grid_x.width = 2
		g_size += 1
		grid_x.default_color = Color("005900")
		if(g_size <= y_axis.get_children().size()-1):
			line.add_child(grid_x)
	
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
	
	set_grid()
	
	#	X-Axis
	for date in RECORDS:
		var label: Label = Label.new()
		label.text = date
		x_axis.add_child(label)
	
	#	Plotting Values
	plot_coordinates()

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

func plot_coordinates() -> void:
	# Wait for next frame to ensure layout is complete
	await get_tree().process_frame
	
	var line_2d: Line2D = Line2D.new()
	line.add_child(line_2d)
	
	# Get chart dimensions
	var chart_width: float = line.size.x
	var chart_height: float = line.size.y
	
	# Debug: Check if dimensions are valid
	#print("Chart dimensions: ", chart_width, " x ", chart_height)
	
	if chart_width <= 0 or chart_height <= 0:
		#print("Invalid chart dimensions - waiting longer...")
		await get_tree().create_timer(0.1).timeout
		chart_width = line.size.x
		chart_height = line.size.y
		#print("New dimensions: ", chart_width, " x ", chart_height)
	
	# Get your Y-axis range (from your segments)
	var amount_list: Array = []
	for amount in RECORDS.values():
		for i in amount.values():
			amount_list.append(i)
	
	var max_amount: float = amount_list.max()
	var y_max: float = round_up_to_nice_number(max_amount)  # Your ceiling (2000)
	var y_min: float = 0.0
	
	# Get sorted dates for X-axis positioning
	var sorted_dates: Array = RECORDS.keys()
	sorted_dates.sort()
	
	# Plot each date's total amount
	for date_index in range(sorted_dates.size()):
		var date = sorted_dates[date_index]
		
		# Calculate total amount for this date
		var total_amount: float = 0.0
		for time_amount in RECORDS[date].values():
			total_amount += time_amount
		
		# Convert to pixel coordinates
		var pixel_pos = data_to_pixel_coords(date_index, total_amount, sorted_dates.size(), y_min, y_max, chart_width, chart_height)
		line_2d.add_point(pixel_pos)
		
		# Debug: Print coordinates
		#print("Date: ", date, " Amount: ", total_amount, " Pixel: ", pixel_pos)
	
	# Style the line
	line_2d.width = 2.0
	line_2d.default_color = Color.GREEN
	line_2d.antialiased = true

func data_to_pixel_coords(x_index: int, y_value: float, total_x_points: int, y_min: float, y_max: float, chart_width: float, chart_height: float) -> Vector2:
	# Normalize X position (0 to 1)
	var x_normalized: float = float(x_index) / float(total_x_points - 1) if total_x_points > 1 else 0.0
	var pixel_x: float = x_normalized * chart_width
	
	# Normalize Y position (0 to 1)
	var y_normalized: float = (y_value - y_min) / (y_max - y_min)
	var pixel_y: float = chart_height - (y_normalized * chart_height)  # Flip Y (0 at bottom)
	
	return Vector2(pixel_x, pixel_y)

func update_plotted_coordinates() -> void:
	for i in line.get_children():
		if i is Line2D:
			i.queue_free()
	set_grid()
	plot_coordinates()
	
