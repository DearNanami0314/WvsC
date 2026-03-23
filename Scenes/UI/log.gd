class_name BattleLogUI
extends Control

@export var max_lines: int = 50

@onready var content_label: RichTextLabel = %ContentLabel

var _lines: Array[String] = []


func _ready() -> void:
	Events.battle_log_appended.connect(_on_battle_log_appended)
	_append_line("[Log] 已连接战斗日志")


func _on_battle_log_appended(message: String) -> void:
	_append_line(message)


func _append_line(message: String) -> void:
	_lines.append(message)
	if _lines.size() > max_lines:
		_lines = _lines.slice(_lines.size() - max_lines, _lines.size())

	content_label.text = "\n".join(_lines)
	await get_tree().process_frame
	content_label.scroll_to_line(content_label.get_line_count())
