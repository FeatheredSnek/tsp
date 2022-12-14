extends Node2D

class_name SfxServer

enum {
	ENEMY_SHOT_1,
	ENEMY_SHOT_2,
	ENEMY_SHOT_QUIET,
	}

enum {
	PLAYER_SHOT, 
	PLAYER_SHOT_SHADOW, 
	PLAYER_BOMB, 
	PLAYER_JEX_SHOT,
	PLAYER_ENTER_SHADOWREALM,
	PLAYER_EXIT_SHADOWREALM,
	PLAYER_BULLET_HIT
	PLAYER_BULLET_HIT_SHADOWREALM,
	PLAYER_GET_HIT
	PLAYER_COLLECT,
	PLAYER_GRAZE,
	PLAYER_SHADOWGAUGE_MAX,
	ENEMY_EXPLODE,
	BOSS_ATTACK_GATHER,
	BOSS_SPELL_GATHER,
	BOSS_BLING,
	BOSS_END,
	BOSS_WARNING,
	ENEMY_WIND
	}


func _ready():
	pass
