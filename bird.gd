class_name Player
extends CharacterBody2D

@export var  side_move: float = 170.0
@export var  jump_force: float = -100.0
@export var  gravity: float = 120.0
@export var  tilt_angle: float = 0.05
@export var  Start_Pos: Vector2 = Vector2(70.0, 205.0)

@onready var anim:AnimatedSprite2D = $AnimatedSprite2D

signal died


var dead:bool = false
var active:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("airplane_Fly")
	velocity.x = side_move
	position = Start_Pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if active:
		velocity.y += gravity * _delta
		
		if is_on_floor() or is_on_ceiling():
			die()
	
	
	
		if Input.is_action_just_pressed("flap") and not dead:
			velocity.y = jump_force
	
		anim.rotation_degrees = velocity.y * tilt_angle
	
	move_and_slide()

func die() -> void:
	if dead:
		return
	
	dead = true
	
	velocity.x = 0
	velocity.y = 0
	anim.play("die_airplane")
	died.emit()


func activate() -> void:
	active = true
	velocity.y = -jump_force


func reset() -> void:
	position = Start_Pos
	active = false 
	dead = false
	velocity.x = side_move
	anim.play("airplane_Fly")
