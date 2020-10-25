extends Area2D

var tilemap
var speed = 80
var direction : Vector2
var attack_damage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tilemap = get_tree().root.get_node("Root/TileMap")

func _process(delta):
	position = position + speed * delta * direction


func _on_Fireball_body_entered(body: Node) -> void:
	if body.name == "Player":
		return
	
	if body.name == "TileMap":
		var cell_coord = tilemap.world_to_map(position)
		var cell_type_id = tilemap.get_cellv(cell_coord)
		if cell_type_id == tilemap.tile_set.find_tile_by_name("Water"):
			return	

	if body.name.find("Skeleton") >= 0:
		body.hit(attack_damage)

	direction = Vector2.ZERO
	$AnimatedSprite.play("explode")


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "explode":
		get_tree().queue_delete(self)


func _on_Timer_timeout() -> void:
	$AnimatedSprite.play("explode")
