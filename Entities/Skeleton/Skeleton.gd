extends KinematicBody2D

signal death

var player

var rnd = RandomNumberGenerator.new()

export var speed = 25
var direction : Vector2
var last_direction = Vector2(0, 1)
var bounce_countdown = 0
var other_animation_playing = false

var health = 100
var health_max = 100
var health_regeneration = 1

var attack_damage = 10
var attack_cooldown_time = 1500
var next_attack_time = 0

func _ready() -> void:
	player = get_tree().root.get_node("Root/Player")
	rnd.randomize()
	
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

func animates_monster(direction: Vector2):
	if direction != Vector2.ZERO:
		last_direction = direction		
		var animation = get_animation_direction(last_direction) + "_walk"
		$AnimatedSprite.play(animation)
	else:		
		var animation = get_animation_direction(last_direction) + "_idle"
		$AnimatedSprite.play(animation)

func _on_Timer_timeout():
	var player_relative_position = player.position - position
	
	if player_relative_position.length() <= 16:
		direction = Vector2.ZERO
		last_direction = player_relative_position.normalized()
	elif player_relative_position.length() <= 100 and bounce_countdown == 0:
		direction = player_relative_position.normalized()
	elif bounce_countdown == 0:		
		var random_number = rnd.randf()
		if random_number < 0.05:
			direction = Vector2.ZERO
		elif random_number < 0.1:
			direction = Vector2.DOWN.rotated(rnd.randf() * 2 * PI)

	if bounce_countdown > 0:
		bounce_countdown = bounce_countdown - 1

func _physics_process(delta):
	var movement = direction * speed * delta	
	var collision = move_and_collide(movement)	
	if collision != null and collision.collider.name != "Player":
		direction = direction.rotated(rnd.randf_range(PI/4, PI/2))
		bounce_countdown = rnd.randi_range(2, 5)		
	if not other_animation_playing:
		animates_monster(direction)
	
	if direction != Vector2.ZERO:
		$RayCast2D.cast_to = direction.normalized() * 16

func arise():
	other_animation_playing = true
	$AnimatedSprite.play("birth")
	
func hit(damage):
	health -= damage
	if health > 0:
		$AnimationPlayer.play("Hit")
	else:
		$Timer.stop()
		direction = Vector2.ZERO
		set_process(false)
		other_animation_playing = true
		$AnimatedSprite.play("death")
		emit_signal("death")

func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "birth":
		$AnimatedSprite.animation = "down_idle"
		$Timer.start()
	elif $AnimatedSprite.animation == "death":
		get_tree().queue_delete(self)
	other_animation_playing = false
	
func _process(delta):	
	health = min(health + health_regeneration * delta, health_max)
	
	var now = OS.get_ticks_msec()
	if now >= next_attack_time:	
		var target = $RayCast2D.get_collider()
		if target != null and target.name == "Player" and player.health > 0:
			other_animation_playing = true
			var animation = get_animation_direction(last_direction) + "_attack"
			$AnimatedSprite.play(animation)
			next_attack_time = now + attack_cooldown_time


func _on_AnimatedSprite_frame_changed() -> void:
	if $AnimatedSprite.animation.ends_with("_attack") and $AnimatedSprite.frame == 1:
		var target = $RayCast2D.get_collider()
		if target != null and target.name == "Player" and player.health > 0:
			player.hit(attack_damage)
