class_name HandUI
extends HBoxContainer

const CARD_UI_SCENE := preload("res://Scenes/CardUI/card_ui.tscn")
const PATTERN_ENGINE_SCRIPT := preload("res://Core/Pattern/pattern_engine.gd")

# =========================================================
# 手牌可视化容器
# 职责：监听 Events.hand_changed 并刷新手牌 UI
# =========================================================

var pattern_engine = PATTERN_ENGINE_SCRIPT.new()
var selected_ids: Dictionary = {}
var selected_cards: Array = []


func _ready() -> void:
	Events.hand_changed.connect(_on_hand_changed)


func _on_hand_changed(cards: Array) -> void:
	_render_cards(cards)


func _render_cards(cards: Array) -> void:
	# 清理失效选中（手牌变化后可能已有卡被打出）
	_prune_selection(cards)

	for child in get_children():
		child.queue_free()

	for card_data: CardData in cards:
		var card_ui := CARD_UI_SCENE.instantiate() as CardUI
		add_child(card_ui)
		card_ui.card_data = card_data
		card_ui.clicked.connect(_on_card_ui_clicked)
		card_ui.selected = selected_ids.has(card_data.id)

	_update_pattern_hint()


func _on_card_ui_clicked(card_data: CardData) -> void:
	if not card_data:
		return

	if selected_ids.has(card_data.id):
		selected_ids.erase(card_data.id)
		Events.card_unselected.emit(card_data)
	else:
		selected_ids[card_data.id] = true
		Events.card_selected.emit(card_data)

	# 刷新当前 UI 的高亮状态
	for child in get_children():
		var card_ui := child as CardUI
		if card_ui:
			card_ui.selected = selected_ids.has(card_ui.card_data.id)

	_update_pattern_hint()


func request_play_selected() -> void:
	if selected_cards.is_empty():
		print("[HandUI] 当前未选牌，无法打出")
		return

	Events.play_cards_requested.emit(selected_cards.duplicate())


func request_discard_selected() -> void:
	if selected_cards.is_empty():
		print("[HandUI] 当前未选牌，无法弃置")
		return

	Events.discard_cards_requested.emit(selected_cards.duplicate())


func _prune_selection(current_cards: Array) -> void:
	var alive_ids := {}
	for c: CardData in current_cards:
		alive_ids[c.id] = true

	var to_remove: Array = []
	for id in selected_ids.keys():
		if not alive_ids.has(id):
			to_remove.append(id)

	for id in to_remove:
		selected_ids.erase(id)


func _update_pattern_hint() -> void:
	selected_cards.clear()
	for child in get_children():
		var card_ui := child as CardUI
		if card_ui and card_ui.card_data and selected_ids.has(card_ui.card_data.id):
			selected_cards.append(card_ui.card_data)

	var pattern_type: int = pattern_engine.detect(selected_cards)
	var pattern_text := PatternTypes.to_text(pattern_type)
	Events.pattern_updated.emit(pattern_type, pattern_text)
