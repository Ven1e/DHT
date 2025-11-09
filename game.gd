class_name GamePlay
extends Node2D

@onready var camera: Camera2D = %Camera2D
@onready var Pipe_container: Node2D = $Pipe_container
@onready var ScoreLabel: Label = %ScoreLabel
@onready var StartLabel: Label = %StartLabel
@onready var WellcomeLabel: Label = %WellcomeLabel
@onready var TitleLabel: Label = %TitleLabel
@onready var PipesTimer: Timer = $pipes_time
@onready var player: CharacterBody2D = $bird
@onready var BlackOut:ColorRect = %BlackOut
@onready var GameOverTimer: Timer = $GameOverTimer
@onready var HighScoreCounter: Control = %HighScoreCounter
@onready var HighScoreLabel:Label = %HighScoreLabel


@export var camera_move: float = 100.0

@export var PIPES = preload("res://scene/pipes.tscn")
@export var PIPE_Y_RANGE: Vector2 = Vector2(200.0, 500.0)
@export var PIPE_X_OFFSET: float = 300.0

var score: = 0
var high_score: = 0
var running: bool = false

func _ready() -> void:
	ScoreLabel.show()
	
	StartLabel.show()
	if FileAccess.file_exists("user://highscore.save"):
		high_score = load_high_score()
		
	else:
		save_high_score()
	HighScoreCounter.hide()



func _process(_delta: float) -> void:
	if running:
		check_pipes()
	elif Input.is_action_just_pressed("flap"):
		start_game()


func _on_pipes_time_timeout() -> void:
	spawn_pipes()

func start_game() -> void:
	running = true
	StartLabel.hide()
	WellcomeLabel.hide()
	TitleLabel.hide()
	PipesTimer.start()
	player.activate()

func reset_game() -> void:
	running = false
	score = 0
	ScoreLabel.text = "0"
	StartLabel.show()
	HighScoreCounter.hide()
	remove_pipes()
	player.reset()



func spawn_pipes() -> void:
	var new_pipes = PIPES.instantiate()
	var y_pos = randf_range(PIPE_Y_RANGE.x, PIPE_Y_RANGE.y)
	new_pipes.position = Vector2(camera.get_screen_center_position().x + PIPE_X_OFFSET, y_pos)
	new_pipes.score_point.connect(score_point)
	Pipe_container.add_child(new_pipes)

func check_pipes() -> void:
	if Pipe_container.get_child_count() > 0:
		var first_pipes = Pipe_container.get_child(0)
		if first_pipes.position.x < camera.get_screen_center_position().x - PIPE_X_OFFSET:
			first_pipes.queue_free()

func remove_pipes() -> void:
	for pipes in Pipe_container.get_children():
		pipes.queue_free()


func score_point() -> void:
	score += 1
	ScoreLabel.text = str(score)
	print(score)


func _on_bird_died() -> void:
	PipesTimer.stop()
	
	HighScoreCounter.show()
	if score > high_score:
		high_score = score
		%HighScoreLabel.text = "New High Score: " + str(high_score)
		save_high_score()
	else:
		%HighScoreLabel.text = "High Score: " + str(high_score)


func _RestartGame() -> void:
		Game_Over_Timer()


func Game_Over_Timer() -> void:
	var _tween: Tween = get_tree().create_tween()
	_tween.tween_property(BlackOut, "color:a", 1.0, 1.0)
	_tween.tween_callback(reset_game)
	_tween.tween_property(BlackOut, "color:a", 0.0, 1.0)



func _on_game_over_timer_timeout() -> void:
	#var _tween: Tween = get_tree().create_tween()
	#_tween.tween_property(BlackOut, "color:a", 1.0, 1.0)
	#_tween.tween_callback(reset_game)
	#_tween.tween_property(BlackOut, "color:a", 0.0, 1.0)
	pass


func save_high_score():
	var file = FileAccess.open("res://highscore.save", FileAccess.WRITE)
	file.store_var(high_score)
	file.close()
			
	print("game-save")




func load_high_score():
	if FileAccess.file_exists("res://highscore.save"):
		var file = FileAccess.open("res://highscore.save", FileAccess.READ)
		var loaded_score = file.get_var()
		file.close()
		return loaded_score
	return 0


func _on_reset_high_pressed() -> void:
	high_score = 0
	save_high_score()
