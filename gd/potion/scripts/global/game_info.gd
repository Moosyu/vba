extends Node

const PHYSICAL_KEYCODE_OPTIONS: Array[int] = [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90]
const MAX_TIME: int = 45
const ROUND_COUNT: int = 6
const VICTORY_SCREEN = preload("res://scenes/victory_screen.tscn")

var round_num: int
var current_round_details: Round
var round_over: bool
var ingredient_index: int
var round_ingredient_minigame_option_indexes: Array[int]
var ingredient_step_index: int
var total_ingredient_step: int
var bottled: bool
var typing_accuracy: int
var drawing_accuracy: int
var cork_speed: float
var game_paused: bool
var selected_potions: Array[Potion]
var stars_counted: int

func _ready() -> void:
	reset_values()

func reset_values() -> void:
	current_round_details = Round.new()
	round_num = 0
	ingredient_index = 0
	ingredient_step_index = 0
	current_round_details.selected_potion = Potions.all_usable_potions.pick_random()
	total_ingredient_step = 0
	bottled = false
	typing_accuracy = 0
	drawing_accuracy = 0
	cork_speed = 0.0
	reset_trackers()
	selected_potions.clear()
	round_ingredient_minigame_option_indexes.clear()
	round_over = false
	stars_counted = 0

## run when moving between turns, moves between ingredient, bottling and round over steps
func increment_turn() -> void:
	if current_round_details.selected_potion.ingredients[ingredient_index].preperation_minigames.size() - 1 > ingredient_step_index:
		ingredient_step_index += 1
		total_ingredient_step += 1
		return
	if current_round_details.selected_potion.ingredients.size() - 1 > ingredient_index:
		ingredient_index += 1
		ingredient_step_index = 0
		total_ingredient_step += 1
		return
	if not bottled:
		bottled = true
		total_ingredient_step += 1
		return
	round_over = true

## should be run every round
func get_new_options_index() -> void:
	round_ingredient_minigame_option_indexes.clear()
	
	for ingredient: Ingredient in current_round_details.selected_potion.ingredients:
		for minigame_options: MinigameOptions in ingredient.preperation_minigames:
			round_ingredient_minigame_option_indexes.append(randi_range(0, minigame_options.minigames.size() - 1))

## gets total number of minigames
func get_total_minigames() -> int:
	var total: int = 0
	for ingredient: Ingredient in current_round_details.selected_potion.ingredients:
		total += ingredient.preperation_minigames.size()
	return total

## gets the max possible score from cutting or drawing type minigames (assuming max score per-minigame is 1). returns this score.
## this WONT work for bottling as its score is calculated with time
func get_max_minigame_score(minigame_type: Minigame.MinigameTypes) -> Dictionary[String, Variant]:
	var score: int = 0
	var ingredient_count_index: int = 0
	
	if minigame_type == Minigame.MinigameTypes.BOTTLING:
		return {"score": 0, "valid": false}

	for ingredient: Ingredient in current_round_details.selected_potion.ingredients:
		for minigame_options: MinigameOptions in ingredient.preperation_minigames:
			if minigame_options.minigames[round_ingredient_minigame_option_indexes[ingredient_count_index]].minigame_type == minigame_type:
					score += 1
			ingredient_count_index += 1

	if score == 0:
		return {"score": 0, "valid": false}
	return {"score": score, "valid": true}

func increment_round() -> void:
	round_num += 1
	if round_num < ROUND_COUNT:
		ingredient_index = 0
		ingredient_step_index = 0
		total_ingredient_step = 0
		bottled = false
		round_over = false
		if round_num != ROUND_COUNT - 1:
			# the filter is removing the current potion from selection so there aren't double ups
			current_round_details.selected_potion = Potions.all_usable_potions.filter(func(potion: Potion): return !selected_potions.has(potion)).pick_random()
		else:
			current_round_details.selected_potion = load("res://resources/potions/life_elixir.tres")
		selected_potions.append(current_round_details.selected_potion)
	else:
		get_tree().change_scene_to_packed(VICTORY_SCREEN)

## returns the minigame currently being attempted, should be ran after incrementing turns and similar
func get_current_minigame() -> Minigame:
	if total_ingredient_step >= get_total_minigames():
		var bottling_minigame: Minigame = Minigame.new()
		bottling_minigame.minigame_type = Minigame.MinigameTypes.BOTTLING
		return bottling_minigame
	return current_round_details.selected_potion.ingredients[ingredient_index].preperation_minigames[ingredient_step_index].minigames[round_ingredient_minigame_option_indexes[total_ingredient_step]]

func update_time_left(current_time: float) -> void:
	current_round_details.time = current_time

func reset_trackers() -> void:
	typing_accuracy = 0
	drawing_accuracy = 0
	cork_speed = 0.0

func get_current_ingredient() -> Ingredient:
	return current_round_details.selected_potion.ingredients[ingredient_index]
