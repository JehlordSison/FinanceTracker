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

@onready var y_axis = $"Y-axis"
@onready var x_axis = $"ScrollContainer/VSplitContainer/X-axis"

@onready var table = $ScrollContainer/VSplitContainer/Table

@export_category("Y-Axis Settings")
@export var y_segment_count: int = 5

func _ready():
	sort_transactions()
	set_axis()
	
func set_grid() -> void:
	await get_tree().process_frame
	#	Y-Axis
	for i in y_axis.get_children():
		var grid_x: Line2D = Line2D.new()
		grid_x.add_point(Vector2(2,i.position.y + (i.size.y/2)))
		grid_x.add_point(Vector2(table.size.x,  i.position.y + (i.size.y/2)))
		grid_x.width = 2
		grid_x.default_color = Color("005900")
		table.add_child(grid_x)
	
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
		label.text = str( i)
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
	var polygon_2d: Polygon2D = Polygon2D.new()
	var poly_points: PackedVector2Array = []
	table.add_child(line_2d)
	
	# Get chart dimensions
	var chart_width: float = table.size.x
	var chart_height: float = table.size.y
	
	# Debug: Check if dimensions are valid
	if chart_width <= 0 or chart_height <= 0:
		await get_tree().create_timer(0.1).timeout
		chart_width = table.size.x
		chart_height = table.size.y
	
	# Get your Y-axis range (from your segments)
	var amount_list: Array = []
	for amount in RECORDS.values():
		for i in amount.values():
			amount_list.append(i)
	
	var max_amount: float = amount_list.max()
	var y_max: float = round_up_to_nice_number(max_amount)  # Your ceiling
	var y_min: float = 0.0
	
	# Get sorted dates for X-axis positioning
	var sorted_dates: Array = RECORDS.keys()
	sorted_dates.sort()
	
	# Get the baseline Y position (where y_value = 0)
	var baseline_y: float = get_y_position_from_labels(0.0, y_min, y_max)
	
	# Add starting point at baseline (bottom-left corner of the filled area)
	if sorted_dates.size() > 0:
		var first_x = data_to_pixel_coords(0, 0.0, sorted_dates.size(), y_min, y_max, chart_width, chart_height).x
		poly_points.append(Vector2(first_x, baseline_y))
	
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
		poly_points.append(pixel_pos)
	
	# Close the polygon by adding the end point at baseline (bottom-right corner)
	if sorted_dates.size() > 0:
		var last_x = data_to_pixel_coords(sorted_dates.size() - 1, 0.0, sorted_dates.size(), y_min, y_max, chart_width, chart_height).x
		poly_points.append(Vector2(last_x, baseline_y))
	
	# Apply the polygon points
	polygon_2d.polygon = poly_points
	table.add_child(polygon_2d)
	
	# Style
	polygon_2d.color = Color(0, 1, 0, 0.3)  # Semi-transparent green
	line_2d.width = 2.0
	line_2d.default_color = Color.GREEN
	line_2d.antialiased = true

func data_to_pixel_coords(x_index: int, y_value: float, total_x_points: int, y_min: float, y_max: float, chart_width: float, chart_height: float) -> Vector2:
	# Normalize X position (0 to 1)
	var x_normalized: float = float(x_index) / float(total_x_points - 1) if total_x_points > 1 else 0.0
	var pixel_x: float = x_normalized * chart_width
	
	# Get Y position based on actual Y-axis label positions
	var pixel_y: float = get_y_position_from_labels(y_value, y_min, y_max)
	
	return Vector2(pixel_x, pixel_y)

func get_y_position_from_labels(y_value: float, y_min: float, y_max: float) -> float:
	# Get the actual Y-axis label positions
	var y_labels = y_axis.get_children()
	
	if y_labels.size() < 2:
		return 0.0
	
	# Calculate which segment the value falls into
	var value_range = y_max - y_min
	var segments = y_labels.size() - 1
	var segment_value = value_range / segments
	
	# Find which two labels this value falls between
	var segment_index = (y_max - y_value) / segment_value
	var lower_index = int(segment_index)
	var upper_index = lower_index + 1
	
	# Clamp to valid range
	lower_index = clamp(lower_index, 0, y_labels.size() - 1)
	upper_index = clamp(upper_index, 0, y_labels.size() - 1)
	
	if lower_index == upper_index:
		# Exact match with a label
		var label = y_labels[lower_index]
		return label.position.y + (label.size.y / 2)
	else:
		# Interpolate between two labels
		var lower_label = y_labels[lower_index]
		var upper_label = y_labels[upper_index]
		
		var lower_y = lower_label.position.y + (lower_label.size.y / 2)
		var upper_y = upper_label.position.y + (upper_label.size.y / 2)
		
		var interpolation_factor = segment_index - lower_index
		return lerp(lower_y, upper_y, interpolation_factor)

func update_plotted_coordinates() -> void:
	for i in table.get_children():
		if i is Line2D or i is Polygon2D:
			i.queue_free()
	set_grid()
	plot_coordinates()
	
