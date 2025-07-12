extends Node

##	"DATE": {"TIME": "AMOUNT"}
var RECORDS: Dictionary = { }: set = on_update_record

func on_update_record(value) -> void:
	RECORDS = value
	print(RECORDS, "\n succesfully updated")

func _process(delta):
	print(RECORDS)
