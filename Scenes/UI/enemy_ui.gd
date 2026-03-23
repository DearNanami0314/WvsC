class_name EnemyUI
extends Node2D

# =========================================================
# 敌方单位显示（Demo 0.2）
# 职责：
#   - 显示敌方立绘 / HP 条 / HP 数值
#   - 每帧从 defeat_rule 轮询 HP，刷新 UI
# =========================================================

@export var defeat_rule: DefeatRule

@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPLabel


func _ready() -> void:
	_sync_hp()


func _process(_delta: float) -> void:
	_sync_hp()


func _sync_hp() -> void:
	if defeat_rule == null:
		return

	hp_bar.max_value = defeat_rule.initial_enemy_hp
	hp_bar.value = defeat_rule.enemy_hp
	hp_label.text = "HP: %d/%d" % [defeat_rule.enemy_hp, defeat_rule.initial_enemy_hp]
