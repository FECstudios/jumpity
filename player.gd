extends CharacterBody2D

signal hearts_changed(count: int, total: int)
signal player_won
signal player_died

const SPEED = 300.0
const JUMP_VELOCITY = -700.0
const WALL_JUMP_VELOCITY = -600.0
const WALL_JUMP_PUSH = 400.0
const MAX_JUMPS = 2
const DEATH_Y = 1000.0  # bu değerin altına düşünce öl

@onready var sprite = $Sprite2D

var hearts_collected: int = 0
var total_hearts: int = 0
var mood_textures: Array[Texture2D] = []
var jumps_left: int = MAX_JUMPS
var is_dead: bool = false

func _ready() -> void:
	mood_textures = [
		preload("res://sprites/1.png"),
		preload("res://sprites/2.png"),
		preload("res://sprites/3.png"),
		preload("res://sprites/4.png"),
		preload("res://sprites/5.png")
	]
	call_deferred("_count_total_hearts")

func _count_total_hearts() -> void:
	total_hearts = get_tree().get_nodes_in_group("hearts").size()
	update_mood()
	hearts_changed.emit(hearts_collected, total_hearts)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		jumps_left = MAX_JUMPS
	elif is_on_wall() and not is_on_floor():
		jumps_left = MAX_JUMPS

	var direction := Input.get_axis("left", "right")

	if is_on_wall() and not is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = WALL_JUMP_VELOCITY
		velocity.x = get_wall_normal().x * WALL_JUMP_PUSH
		jumps_left = MAX_JUMPS - 1
	elif Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	if is_on_wall() and not is_on_floor() and Input.is_action_just_pressed("jump"):
		pass
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Haritadan düşünce öl
	if global_position.y > DEATH_Y:
		die()

func collect_heart() -> void:
	hearts_collected += 1
	update_mood()
	hearts_changed.emit(hearts_collected, total_hearts)

	if hearts_collected >= total_hearts and total_hearts > 0:
		win()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	player_died.emit()

func win() -> void:
	if is_dead:
		return
	is_dead = true
	player_won.emit()

func update_mood() -> void:
	if total_hearts == 0:
		sprite.texture = mood_textures[0]
		return

	var percent := float(hearts_collected) / float(total_hearts)
	var mood_index := 0
	if percent >= 0.80:
		mood_index = 4
	elif percent >= 0.60:
		mood_index = 3
	elif percent >= 0.40:
		mood_index = 2
	elif percent >= 0.20:
		mood_index = 1
	else:
		mood_index = 0

	sprite.texture = mood_textures[mood_index]
