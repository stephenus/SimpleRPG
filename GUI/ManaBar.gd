extends ColorRect



func _on_Player_player_stats_changed(var player) -> void:
	$Bar.rect_size.x = 72 * player.mana / player.mana_max
