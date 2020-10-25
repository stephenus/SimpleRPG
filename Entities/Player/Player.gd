extends KinematicBody2D

export var speed = 75

var health = 100
var health_max = 100
var health_regeneration = 1
var mana = 100
var mana_max = 100
var mana_regeneration = 2

var last_direction = Vector2(0, 1)

var attack_playing = false

signal player_stats_changed

func _ready():
	emit_signal("player_stats_changed", self)
	
func _process(delta):	
	var new_mana = min(mana + mana_regeneration * delta, mana_max)
	if new_mana != mana:
		mana = new_mana
		emit_signal("player_stats_changed", self)
	
	var new_health = min(health + health_regeneration * delta, health_max)
	if new_health != health:
		health = new_health
		emit_signal("player_stats_changed", self)

func _physics_process(delta):
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()	
	
	var movement = speed * direction * delta
	if attack_playing:
		movement = 0.3 * movement	
	move_and_collide(movement)
	if not attack_playing:
		animates_player(direction)

func animates_player(direction: Vector2):
	if direction != Vector2.ZERO:
		last_direction = 0.5 * last_direction + 0.5 * direction
		var animation = get_animation_direction(last_direction) + "_walk"
		$Sprite.frames.set_animation_speed(animation, 2 + 8 * direction.length())
		$Sprite.play(animation)
	else:
		var animation = get_animation_direction(last_direction) + "_idle"
		$Sprite.play(animation)

func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.y >= 0.707:
		return "down"
	elif norm_direction.y <= -0.707:
		return "up"
	elif norm_direction.x <= -0.707:
		return "left"
	elif norm_direction.x >= 0.707:
		return "right"
	return "down"
	
func _input(event):
	if event.is_action_pressed("attack"):
		attack_playing = true
		var animation = get_animation_direction(last_direction) + "_attack"
		$Sprite.play(animation)
	elif event.is_action_pressed("fireball"):
		if mana >= 25:
			mana = mana - 25
			emit_signal("player_stats_changed", self)
			attack_playing = true
			var animation = get_animation_direction(last_direction) + "_fireball"
			$Sprite.play(animation)


func _on_Sprite_animation_finished() -> void:
	attack_playing = false
