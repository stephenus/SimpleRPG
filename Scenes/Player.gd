extends KinematicBody2D

export var speed = 75

func _physics_process(delta):
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()	
	
	var movement = speed * direction * delta
	move_and_collide(movement)
