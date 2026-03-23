class_name Enemy
extends Node2D

@onready var enemy_ui = $EnemyUI


func set_defeat_rule(rule: DefeatRule) -> void:
	enemy_ui.defeat_rule = rule
