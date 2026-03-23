extends PanelContainer

# =========================================================
# 敌方意图显示 UI（Day5 MVP）
# 职责：监听 Events.enemy_intent_changed，显示敌人下一步动作
# 格式：Intent: Attack (X) / Intent: Defend
# =========================================================

@onready var intent_label: Label = $MarginContainer/IntentLabel


func _ready() -> void:
	Events.enemy_intent_changed.connect(_on_enemy_intent_changed)
	Events.enemy_action_completed.connect(_on_enemy_action_completed)
	_show_default()


func _on_enemy_intent_changed(action: String, value: int) -> void:
	match action:
		"attack":
			intent_label.text = "Intent: Attack (%d)" % value
		"defend":
			intent_label.text = "Intent: Defend"
		_:
			intent_label.text = "Intent: %s" % action
	show()


func _on_enemy_action_completed(_enemy) -> void:
	# 动作完成后保持显示（已被 enemy_intent_changed 更新为下回合预测）
	pass


func _show_default() -> void:
	intent_label.text = "Intent: —"
