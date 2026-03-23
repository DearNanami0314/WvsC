class_name BattleHUD
extends CanvasLayer

# =========================================================
# 战斗 HUD 总控（Day5 — 替代原 BattleUI）
# 职责：
#   1. 容纳 HandUI / PatternHintUI / IntentUI 三个子面板
#   2. 连接按钮交互与全局事件
#   3. 按回合/阶段切换按钮可用性
# 层级：CanvasLayer → Control(HUDRoot) → 各子 UI
# =========================================================

@onready var hand_ui: HandUI = %HandUI
@onready var play_cards_button: Button = %PlayCardsButton
@onready var end_play_phase_button: Button = %EndPlayPhaseButton
@onready var discard_selected_button: Button = %DiscardSelectedButton
@onready var end_enemy_turn_button: Button = %EndEnemyTurnButton
@onready var subtitle_label: Label = %SubtitleLabel

var current_phase: int = Phase.PlayerPhase.TURN_START
var subtitle_tween: Tween
var is_battle_over := false

const PHASE_SUBTITLE_DURATION := 1.0
const PHASE_FLOAT_DISTANCE := 5.0
const SUBTITLE_BASE_TOP := -7.0
const SUBTITLE_BASE_BOTTOM := 7.0


func _ready() -> void:
	play_cards_button.pressed.connect(_on_play_cards_button_pressed)
	end_play_phase_button.pressed.connect(_on_end_play_phase_button_pressed)
	discard_selected_button.pressed.connect(_on_discard_selected_button_pressed)
	end_enemy_turn_button.pressed.connect(_on_end_enemy_turn_button_pressed)

	Events.turn_started.connect(_on_turn_started)
	Events.phase_changed.connect(_on_phase_changed)
	Events.battle_over_screen_requested.connect(_on_battle_over_screen_requested)


func _on_play_cards_button_pressed() -> void:
	hand_ui.request_play_selected()


func _on_end_play_phase_button_pressed() -> void:
	if current_phase == Phase.PlayerPhase.PLAY:
		Events.phase_advance_requested.emit()


func _on_discard_selected_button_pressed() -> void:
	hand_ui.request_discard_selected()


func _on_end_enemy_turn_button_pressed() -> void:
	# 测试按钮：手动结束敌方回合
	Events.enemy_turn_ended.emit()


func _on_turn_started(side) -> void:
	if is_battle_over:
		return

	var is_player_turn: bool = side == Phase.Side.PLAYER
	if not is_player_turn:
		play_cards_button.disabled = true
		end_play_phase_button.disabled = true
		discard_selected_button.disabled = true
		end_enemy_turn_button.disabled = false
		_show_phase_subtitle("敌方回合")
		return

	# 玩家回合下，按钮按阶段控制
	_update_buttons_by_phase(current_phase)
	end_enemy_turn_button.disabled = true


func _on_phase_changed(phase) -> void:
	if is_battle_over:
		return

	current_phase = phase
	_update_buttons_by_phase(phase)
	_show_phase_subtitle(_phase_to_text(phase))


func _update_buttons_by_phase(phase: int) -> void:
	play_cards_button.disabled = phase != Phase.PlayerPhase.PLAY
	end_play_phase_button.disabled = phase != Phase.PlayerPhase.PLAY
	discard_selected_button.disabled = phase != Phase.PlayerPhase.DISCARD


func _on_battle_over_screen_requested(text: String, _type) -> void:
	is_battle_over = true
	_show_subtitle(text, true)


func _show_phase_subtitle(text: String) -> void:
	_show_subtitle(text, false)


func _show_subtitle(text: String, persistent: bool) -> void:
	if subtitle_tween:
		subtitle_tween.kill()

	subtitle_label.text = text
	subtitle_label.visible = true
	subtitle_label.modulate = Color(1, 1, 1, 1)
	subtitle_label.offset_top = SUBTITLE_BASE_TOP
	subtitle_label.offset_bottom = SUBTITLE_BASE_BOTTOM

	if persistent:
		return

	subtitle_tween = create_tween()
	subtitle_tween.set_parallel(true)
	subtitle_tween.tween_property(subtitle_label, "offset_top", SUBTITLE_BASE_TOP - PHASE_FLOAT_DISTANCE, PHASE_SUBTITLE_DURATION)
	subtitle_tween.tween_property(subtitle_label, "offset_bottom", SUBTITLE_BASE_BOTTOM - PHASE_FLOAT_DISTANCE, PHASE_SUBTITLE_DURATION)
	subtitle_tween.tween_property(subtitle_label, "modulate:a", 0.0, PHASE_SUBTITLE_DURATION)
	await subtitle_tween.finished

	# 仅在未被后续字幕覆盖时隐藏
	if subtitle_label.text == text:
		subtitle_label.visible = false
		subtitle_label.offset_top = SUBTITLE_BASE_TOP
		subtitle_label.offset_bottom = SUBTITLE_BASE_BOTTOM


func _phase_to_text(phase: int) -> String:
	match phase:
		Phase.PlayerPhase.TURN_START:
			return "回合开始"
		Phase.PlayerPhase.DRAW:
			return "抽牌阶段"
		Phase.PlayerPhase.PLAY:
			return "出牌阶段"
		Phase.PlayerPhase.DISCARD:
			return "弃牌阶段"
		Phase.PlayerPhase.TURN_END:
			return "回合结束"
		_:
			return "阶段切换"
