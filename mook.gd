extends CharacterBody2D


@export var SPEED := 55.0
@export var JUMP_HEIGHT := 23.0
@export var ASCENT_TIME := 0.25
@export var DESCENT_TIME := 0.10
@export var LOCK_JUMP_DIRECTION := false

var facing_right := true
var on_rope := false


func _ready() -> void:
	$AnimatedSprite2D.play()


func _process(_delta: float) -> void:
	if facing_right:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
	
	if velocity.x == 0:
		$AnimatedSprite2D.animation = "idle"
	else:
		$AnimatedSprite2D.animation = "walking"


func _physics_process(delta: float) -> void:
	var JUMP_VELOCITY := -2.0 * (JUMP_HEIGHT / ASCENT_TIME)
	var ASCENT_GRAVITY := -JUMP_VELOCITY / ASCENT_TIME
	var DESCENT_GRAVITY := -JUMP_VELOCITY / DESCENT_TIME
	var TERMINAL_VELOCITY := -JUMP_VELOCITY
	# Add the gravity.
	if not is_on_floor() and velocity.y < 0:
		velocity.y += ASCENT_GRAVITY * delta
		velocity.y = clamp(velocity.y, JUMP_VELOCITY, TERMINAL_VELOCITY)
	elif not is_on_floor():
		velocity.y += DESCENT_GRAVITY * delta
		velocity.y = clamp(velocity.y, JUMP_VELOCITY, TERMINAL_VELOCITY)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	var can_move = not LOCK_JUMP_DIRECTION or is_on_floor()
	if direction and can_move:
		velocity.x = direction * SPEED
	elif is_on_floor( ):
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if velocity.x > 0:
		facing_right = true
	elif velocity.x < 0:
		facing_right = false

	move_and_slide()


func _on_rope_collider_body_entered(body: Node2D) -> void:
	on_rope = true


func _on_rope_collider_body_exited(body: Node2D) -> void:
	on_rope = false
