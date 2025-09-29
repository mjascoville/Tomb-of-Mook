extends CharacterBody2D


@export var SPEED := 55.0
@export var JUMP_HEIGHT := 23.0
@export var ASCENT_TIME := 0.25
@export var DESCENT_TIME := 0.10
@export var LOCK_JUMP_DIRECTION := false

enum State {
	Ground,
	Air,
	Rope,
	Roll,
}

var state = State.Ground
var facing_right := true
var on_rope := false


func _ready() -> void:
	$AnimatedSprite2D.play()


func _process(_delta: float) -> void:
	if facing_right:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true


func _physics_process(delta: float) -> void:
	var jump_velocity := -2.0 * (JUMP_HEIGHT / ASCENT_TIME)
	var ascent_gravity := -jump_velocity / ASCENT_TIME
	var descent_gravity := -jump_velocity / DESCENT_TIME
	var terminal_velocity := 2.0 * (JUMP_HEIGHT / DESCENT_TIME)

	match state:
		State.Ground:
			var direction := Input.get_axis("ui_left", "ui_right")
			#var can_move = not LOCK_JUMP_DIRECTION or is_on_floor()
			if not is_on_floor():
				state = State.Air
			elif direction:
				velocity.x = direction * SPEED
				$AnimatedSprite2D.play("walking")
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				$AnimatedSprite2D.play("idle")
			
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = jump_velocity
				state = State.Air
				$AnimatedSprite2D.play("jump")
			if velocity.y > 0: 
				$AnimatedSprite23.play("fall") 
			
			if on_rope and (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")):
				state = State.Rope
		State.Air:
			if not LOCK_JUMP_DIRECTION:
				var direction := Input.get_axis("ui_left", "ui_right")
				if direction:
					velocity.x = direction * SPEED
				else:
					velocity.x = move_toward(velocity.x, 0, SPEED)
			# Add the gravity.
			if not is_on_floor() and velocity.y < 0:
				velocity.y += ascent_gravity * delta
				velocity.y = clamp(velocity.y, jump_velocity, terminal_velocity)
			elif not is_on_floor():
				velocity.y += descent_gravity * delta
				velocity.y = clamp(velocity.y, jump_velocity, terminal_velocity)
				$AnimatedSprite2D.play("fall")
			elif is_on_floor():
				state = State.Ground
		State.Rope:
			collision_mask = 0
			if is_on_floor() and Input.is_action_pressed("ui_down"):
				state = State.Ground
				collision_mask = 1
			elif is_on_floor() and velocity.y < 0:
				state = State.Ground
				collision_mask = 1
			elif not on_rope:
				state = State.Air
				collision_mask = 1
			
			$AnimatedSprite2D.play("climb")
			
			if Input.is_action_pressed("ui_up"):
				velocity.y = -SPEED
			elif Input.is_action_pressed("ui_down"):
				velocity.y = SPEED
			else:
				velocity.y = 0
			
		State.Roll:
			pass

	if velocity.x > 0:
		facing_right = true
	elif velocity.x < 0:
		facing_right = false

	move_and_slide()


func _on_rope_collider_body_entered(_body: Node2D) -> void:
	on_rope = true


func _on_rope_collider_body_exited(_body: Node2D) -> void:
	on_rope = false
