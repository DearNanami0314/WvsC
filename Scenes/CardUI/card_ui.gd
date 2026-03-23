class_name CardUI
extends Control

signal clicked(card_data: CardData)

# =========================================================
# 卡牌可视化控件（对标教程 card_ui.gd 的数据注入写法）
# 当前先实现展示，不做拖拽状态机
# =========================================================

@export var card_data: CardData : set = _set_card_data

@onready var title: Label = $Panel/VBox/Title
@onready var panel: Panel = $Panel
@onready var hitbox: Button = $Hitbox

var selected := false : set = set_selected


func _set_card_data(value: CardData) -> void:
	if not is_node_ready():
		await ready

	card_data = value
	if not card_data:
		title.text = ""
		
		return

	title.text = card_data.get_short_text()



func _ready() -> void:
	hitbox.pressed.connect(_on_hitbox_pressed)


func _on_hitbox_pressed() -> void:
	clicked.emit(card_data)


func set_selected(value: bool) -> void:
	selected = value
	if not is_node_ready():
		return

	# 选中时轻微高亮
	if selected:
		panel.self_modulate = Color(1.0, 0.85, 0.45, 1.0)
		title.add_theme_color_override("font_color", Color.BLACK)
	else:
		panel.self_modulate = Color(1, 1, 1, 1)
		title.remove_theme_color_override("font_color")
