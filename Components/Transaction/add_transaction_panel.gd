extends Control
@onready var date_edit = $CreatePanel/DatePanel/DateEdit
@onready var time_edit = $CreatePanel/TimePanel/TimeEdit
@onready var amount_edit = $CreatePanel/AmountPanel/AmountEdit

@onready var create_btn = $CreatePanel/CreateBtn
@onready var cancel_btn = $CreatePanel/CancelBtn
@onready var confirm_btn = $CreatePanel/ConfirmBtn
@onready var edit_btn = $CreatePanel/EditBtn

@onready var date_check_btn = $CreatePanel/DatePanel/DateCheckBtn
@onready var time_check_btn = $CreatePanel/TimePanel/TimeCheckBtn
@onready var time_option_btn = $CreatePanel/TimePanel/TimeOptionBtn

var date_valid: bool
var time_valid: bool
var amount_valid: bool
var info: Dictionary ={}
var amount: float
var time_unit: String = "AM"

func _ready():
	if(date_check_btn.button_pressed == true):
		date_check_btn.emit_signal("toggled", true)
	if(time_check_btn.button_pressed == true):
		time_check_btn.emit_signal("toggled", true)

func _process(_delta):
	if(date_valid == true and amount_valid == true and time_valid == true):
		create_btn.disabled = false
	else:
		create_btn.disabled = true

func get_date() -> String:
	var date = Time.get_datetime_dict_from_system()
	var formatted: String = "%02d/%02d/%04d" % [date.month, date.day, date.year]
	return formatted
	
func get_time() -> String:
	var time = Time.get_datetime_dict_from_system()
	
	# Convert 24-hour to 12-hour format
	var hour_12 = time.hour
	var am_pm = "AM"
	
	if time.hour == 0:
		hour_12 = 12  # Midnight is 12 AM
	elif time.hour > 12:
		hour_12 = time.hour - 12
		am_pm = "PM"
	elif time.hour == 12:
		am_pm = "PM"  # Noon is 12 PM
	
	var formatted: String = "%02d:%02d:%02d %s " % [hour_12, time.minute, time.second, am_pm]
	return formatted

func send_info():
	Handler.RECORDS[date_edit.text] = Handler.RECORDS.get(date_edit.text, {})
	Handler.RECORDS[date_edit.text][time_edit.text + " " + time_unit] = amount
	Handler.RECORDS = Handler.RECORDS

#	Validations
func is_valid_date(input: String) -> bool:
	var proper_len: bool
	var proper_input: bool
	var proper_date: bool
	
	var pattern: String = "[A-Z~a-z~!@#$%^&*()_+{}`:;,']"
	var rgx1: RegEx = RegEx.new()
	rgx1.compile(pattern)
	rgx1.get_pattern()
	
	var format: String = "^\\d{2}/\\d{2}/\\d{4}$"
	var rgx2: RegEx = RegEx.new()
	rgx2.compile(format)
	rgx2.get_pattern()
	
	if(rgx1.search(input)):
		proper_input = false
	else:
		proper_input = true
	
	if(input.length() == 10):
		proper_len = true
	else:
		proper_len = false
	
	if(rgx2.search(input)):
		proper_date = true
	else:
		proper_date = false
		
	if(proper_len == true and proper_input == true and proper_date == true):
		return true
	else:
		return false
		
func is_valid_time(input: String) -> bool:
	# Check if input matches hh:mm:ss format
	var format: String = "^\\d{2}:\\d{2}:\\d{2}$"
	var rgx: RegEx = RegEx.new()
	rgx.compile(format)
	
	# Check format match
	if not rgx.search(input):
		return false
	
	# Extract hours, minutes, seconds
	var parts = input.split(":")
	if parts.size() != 3:
		return false
	
	var hours = parts[0].to_int()
	var minutes = parts[1].to_int()
	var seconds = parts[2].to_int()
	
	# Validate time ranges
	if hours < 0 or hours > 23:
		return false
	if minutes < 0 or minutes > 59:
		return false
	if seconds < 0 or seconds > 59:
		return false
	
	return true
	
func is_valid_amount(input: String) -> bool:
	var proper_len: bool
	var proper_input: bool
	var pattern: String = "[A-Z~a-z~!@#$%^&*()_+{}`:;,']"
	var rgx: RegEx = RegEx.new()
	rgx.compile(pattern)
	rgx.get_pattern()
	
	if(rgx.search(input)):
		proper_input = false
	else:
		proper_input = true
	
	if(input.length() > 0):
		proper_len = true
	else:
		proper_len = false
		
	if(proper_len == true and proper_input == true):
		return true
	else:
		return false

#	Date
func _on_date_edit_text_changed(new_text):
	if(is_valid_date(new_text)):
		date_valid = true
	else:
		date_valid = false
		
func _on_date_check_btn_toggled(toggled_on):
	if toggled_on:
		date_edit.text = get_date()
		date_edit.emit_signal("text_changed", date_edit.text)
	date_edit.editable = !toggled_on

#	Time
func _on_time_edit_text_changed(new_text):
	if(is_valid_time(new_text)):
		time_valid = true
	else:
		time_valid = false

func _on_time_check_btn_toggled(toggled_on):
	if(toggled_on):
		time_edit.text = get_time()
		time_edit.emit_signal("text_changed", time_edit.text)
		
	time_edit.editable = !toggled_on
	
	if(get_time().contains("AM")):
		time_option_btn.select(0)
		time_unit = "AM"
	else:
		time_option_btn.select(1)
		time_unit = "PM"

	time_option_btn.disabled = toggled_on

func _on_amount_edit_text_changed(new_text):
	var n: String = amount_edit.text
	if(is_valid_amount(new_text) and n.is_valid_float()):
		amount_valid = true
	else:
		amount_valid = false
		
func _on_amount_edit_focus_exited():
	var n: String = amount_edit.text
	if(n.is_valid_float()):
		amount = float(n)
		amount_edit.text = str("%.2f" % amount)

#	Transaction Type
func _on_status_option_btn_item_selected(index):
	match index:
		0:
			amount *= 1
		1:
			amount *= -1
	
#	Create 
func _on_create_btn_pressed():
	create_btn.hide()
	await get_tree().create_timer(.05).timeout
	confirm_btn.show()
	edit_btn.show()

func _on_edit_btn_pressed():
	confirm_btn.hide()
	edit_btn.hide()
	await get_tree().create_timer(.05).timeout
	create_btn.show()
	
func _on_confirm_btn_pressed():
	send_info()
	await get_tree().process_frame
	queue_free()
	
func _on_cancel_btn_pressed():
	queue_free()
