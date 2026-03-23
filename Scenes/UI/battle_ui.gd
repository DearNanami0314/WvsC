class_name BattleUI
extends CanvasLayer

# =========================================================
# 战斗UI总控（对标教程 battle_ui.gd）
# 职责：连接按钮交互与全局事件
# =========================================================

@onready var hand_ui: HandUI = $HandUI
@onready var play_cards_button: Button = %PlayCardsButton
@onready var end_play_phase_button: Button = %EndPlayPhaseButton
@onready var discard_selected_button: Button = %DiscardSelectedButton
@onready var end_enemy_turn_button: Button = %EndEnemyTurnButton

var current_phase: int = Phase.PlayerPhase.TURN_START


func _ready() -> void:
	play_cards_button.pressed.connect(_on_play_cards_button_pressed)
	end_play_phase_button.pressed.connect(_on_end_play_phase_button_pressed)
	discard_selected_button.pressed.connect(_on_discard_selected_button_pressed)
	end_enemy_turn_button.pressed.connect(_on_end_enemy_turn_button_pressed)

	Events.turn_started.connect(_on_turn_started)
	Events.phase_changed.connect(_on_phase_changed)


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
	var is_player_turn: bool = side == Phase.Side.PLAYER
	if not is_player_turn:
		play_cards_button.disabled = true
		end_play_phase_button.disabled = true
		discard_selected_button.disabled = true
		end_enemy_turn_button.disabled = false
		return

	# 玩家回合下，按钮按阶段控制
	_update_buttons_by_phase(current_phase)
	end_enemy_turn_button.disabled = true


func _on_phase_changed(phase) -> void:
	current_phase = phase
	_update_buttons_by_phase(phase)


func _update_buttons_by_phase(phase: int) -> void:
	play_cards_button.disabled = phase != Phase.PlayerPhase.PLAY
	end_play_phase_button.disabled = phase != Phase.PlayerPhase.PLAY
	discard_selected_button.disabled = phase != Phase.PlayerPhase.DISCARD
