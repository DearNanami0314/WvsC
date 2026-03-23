extends SceneTree

const PatternEngineScript := preload("res://Core/Pattern/pattern_engine.gd")
const PatternTypesScript := preload("res://Core/Pattern/pattern_types.gd")
const CardDataScript := preload("res://CustomResources/card_data.gd")


func _init() -> void:
	print("[test_pattern_engine] start")

	var engine := PatternEngineScript.new()

	var single_cards := [_make_card(7, CardDataScript.Suit.SPADE)]
	var pair_cards := [
		_make_card(9, CardDataScript.Suit.HEART),
		_make_card(9, CardDataScript.Suit.CLUB),
	]
	var triple_cards := [
		_make_card(12, CardDataScript.Suit.SPADE),
		_make_card(12, CardDataScript.Suit.HEART),
		_make_card(12, CardDataScript.Suit.DIAMOND),
	]

	assert(engine.detect(single_cards) == PatternTypesScript.Type.SINGLE)
	assert(engine.detect(pair_cards) == PatternTypesScript.Type.PAIR)
	assert(engine.detect(triple_cards) == PatternTypesScript.Type.THREE_OF_A_KIND)

	print("[test_pattern_engine] PASS")
	quit(0)


func _make_card(rank: int, suit: int) -> CardData:
	var card := CardDataScript.new()
	card.rank = rank
	card.suit = suit
	return card
