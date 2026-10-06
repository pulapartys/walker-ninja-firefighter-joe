extends Resource
## Values from GDD 0.2.0. A shared resource for gameplay and fixtures.
@export var speed: float = 120.0  # was 160 (A1); slowed 2026-10-06 so the poses read (playtest 2)
@export var acceleration: float = 1280.0
@export var deceleration: float = 1920.0
@export var jump_velocity: float = -320.0
@export var gravity: float = 800.0  # was 960 (A1); floatier jump to match the slower run (playtest 2, option A)
@export var terminal_velocity: float = 480.0
@export var coyote_ticks: int = 6
@export var buffer_ticks: int = 6
