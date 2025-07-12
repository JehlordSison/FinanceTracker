extends Node

signal update_record
##	"DATE": {"TIME": "AMOUNT"}
var RECORDS: Dictionary = { }: set = on_update_record
func on_update_record(value) -> void:
	RECORDS = value
	emit_signal("update_record"); print(RECORDS, "\n succesfully updated")
	
