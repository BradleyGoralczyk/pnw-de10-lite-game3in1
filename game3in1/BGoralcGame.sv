/*
 * Bradley Goralczyk's Game
 * Inspired by Google Chrome's Dinosaur Run Game
 */

`default_nettype none

module BGoralcGame
import AlphabetDisplayDriver_pkg::*;
(
	input logic
	key0,  // upper button (jump)
	key1,  // lower button (duck)
	clock_50MHz,
	reset,
	
	output logic [5:0] [7:0]
	hex_leds,
	
	output logic [9:0]
	sw_leds
);

// --------------------------------------------------------------------------------
// Constants
// --------------------------------------------------------------------------------

typedef enum logic [1:0]
{
	DINO_WALK,
	DINO_JUMP,
	DINO_DUCK
} DinoState;

typedef enum logic [1:0]
{
	GAME_TITLE,
	GAME_PLAY,
	GAME_LOSE
} GameState;

typedef enum logic [1:0]
{
	OBSTACLE_NONE = 2'b00,
	OBSTACLE_BIRD = 2'b01,
	OBSTACLE_BUSH = 2'b10
} ObstacleState;

parameter int DIVISOR_BIRDBUSH_MIN = 50 * 1000 * 1000 / 1;
parameter int DIVISOR_BIRDBUSH_MAX = 50 * 1000 * 1000 / 8;

// --------------------------------------------------------------------------------
// Submodule Instantiation
// --------------------------------------------------------------------------------

logic clock_obstacles, clock_obstacles_divisor;
ClockDividerN CLOCK_OBSTACLES
(
	.clock_in (clock_50MHz),
	.reset (game_state != GAME_PLAY),
	.divisor (DIVISOR_BIRDBUSH_MAX),
	.clock_out (clock_obstacles)
);

logic clock_flashing;
ClockDividerN CLOCK_FLASHING
(
	.clock_in (clock_50MHz),
	.reset (game_state != GAME_LOSE),
	.divisor (50 * 1000 * 1000 / 2),
	.clock_out (clock_flashing)
);

logic [31:0] rng_value_obstacles;
LinearCongruentialRNG RNG_OBSTACLES
(
	.clock (clock_obstacles),
	.reset (reset),
	.value (rng_value_obstacles)
);

logic key0_pulse, key1_pulse, anykey_pulse;
LevelToPulse KEY0_PULSE
(
	.level (key0),
	.clock (clock_50MHz),
	.pulse (key0_pulse)
);
LevelToPulse KEY1_PULSE
(
	.level (key1),
	.clock (clock_50MHz),
	.pulse (key1_pulse)
);
assign anykey_pulse = (key0_pulse || key1_pulse);

logic [7:0] hex_leds_char_L, hex_leds_char_O, hex_leds_char_S, hex_leds_char_E;
logic [7:0] hex_leds_char_r, hex_leds_char_u, hex_leds_char_n, hex_leds_char_exclamation;
AlphabetDisplayDriver CHAR_L
(
	.char (ALPHA_L),
	.leds (hex_leds_char_L)
);
AlphabetDisplayDriver CHAR_O
(
	.char (ALPHA_O),
	.leds (hex_leds_char_O)
);
AlphabetDisplayDriver CHAR_S
(
	.char (ALPHA_S),
	.leds (hex_leds_char_S)
);
AlphabetDisplayDriver CHAR_E
(
	.char (ALPHA_E),
	.leds (hex_leds_char_E)
);
AlphabetDisplayDriver CHAR_r
(
	.char (ALPHA_R),
	.leds (hex_leds_char_r)
);
AlphabetDisplayDriver CHAR_u
(
	.char (ALPHA_u),
	.leds (hex_leds_char_u)
);
AlphabetDisplayDriver CHAR_n
(
	.char (ALPHA_N),
	.leds (hex_leds_char_n)
);
AlphabetDisplayDriver CHAR_EXCLAMATION
(
	.char (ALPHA_EXCLAMATION),
	.leds (hex_leds_char_exclamation)
);

// --------------------------------------------------------------------------------
// Obstacle Generator
// --------------------------------------------------------------------------------

logic reset_obstacles;
ObstacleState obstacles [15:0];
always_ff @(posedge clock_obstacles or posedge reset_obstacles) begin
	if (reset_obstacles) begin
		for (int i = 0; i < 16; ++i) begin
			obstacles[i] <= OBSTACLE_NONE;
		end
	end else begin
		for (int i = 1; i < 16; ++i) begin
			obstacles[i] <= obstacles[i - 1];
		end
		// TODO: Don't generate impossible patterns
		if (rng_value_obstacles > 32'h20000000) begin
			obstacles[0] <= OBSTACLE_NONE;
		end else if (rng_value_obstacles > 32'h10000000) begin
			obstacles[0] <= OBSTACLE_BIRD;
		end else begin
			obstacles[0] <= OBSTACLE_BUSH;
		end
	end
end

// --------------------------------------------------------------------------------
// Game Main Loop
// --------------------------------------------------------------------------------

GameState game_state;
DinoState dino_state;
always_ff @(posedge clock_50MHz or posedge reset) begin
	if (reset) begin
		dino_state <= DINO_WALK;
		game_state <= GAME_TITLE;
		reset_obstacles <= 1'b1;
	end else	case (game_state)
		GAME_TITLE: begin
			dino_state <= DINO_WALK;
			game_state <= anykey_pulse ? GAME_PLAY : game_state;
			reset_obstacles <= 1'b1;
		end
		GAME_LOSE: begin
			dino_state <= dino_state;
			game_state <= anykey_pulse ? GAME_TITLE : game_state;
			reset_obstacles <= 1'b0;
		end
		GAME_PLAY: begin
			if (key0 && !key1) begin
				dino_state <= DINO_JUMP;
			end else if (!key0 && key1) begin
				dino_state <= DINO_DUCK;
			end else begin
				dino_state <= DINO_WALK;
			end
			case (obstacles[15])  // Displayed on HEX5
				OBSTACLE_BIRD: if (dino_state == DINO_JUMP || dino_state == DINO_WALK) begin
					game_state <= GAME_LOSE;
				end
				OBSTACLE_BUSH: if (dino_state == DINO_DUCK || dino_state == DINO_WALK) begin
					game_state <= GAME_LOSE;
				end
				default: begin
					game_state <= game_state;
				end
			endcase
			reset_obstacles <= 1'b0;
		end
	endcase
end

// --------------------------------------------------------------------------------
// Display Driver
// --------------------------------------------------------------------------------

ObstacleState obstacles_hex [5:0];
assign obstacles_hex = obstacles[15:10];

ObstacleState obstacles_sw [9:0];
assign obstacles_sw = obstacles[9:0];

logic show_obstacles;
assign show_obstacles = (game_state == GAME_PLAY || clock_flashing);
	
always_comb begin
	// Overcommit to avoid inferred latches and output ports with no driver.
	for (int hex_idx = 0; hex_idx < 6; ++hex_idx) begin
		hex_leds[hex_idx] = 8'b00000000;
	end
	
	hex_leds[5][4] = (dino_state == DINO_WALK | dino_state == DINO_DUCK);
	hex_leds[5][5] = (dino_state == DINO_WALK | dino_state == DINO_JUMP);
	for (int hex_idx = 0; hex_idx < 6; ++hex_idx) begin
		hex_leds[hex_idx][0] = (obstacles_hex[hex_idx] == OBSTACLE_BIRD) && show_obstacles;
		hex_leds[hex_idx][3] = (obstacles_hex[hex_idx] == OBSTACLE_BUSH) && show_obstacles;
	end
	case (game_state)
		GAME_TITLE: begin
			hex_leds[3] = hex_leds_char_r;
			hex_leds[2] = hex_leds_char_u;
			hex_leds[1] = hex_leds_char_n;
			hex_leds[0] = hex_leds_char_exclamation;
		end
		GAME_PLAY: begin
			// Do nothing
		end
		GAME_LOSE: begin
			hex_leds[3] = hex_leds_char_L;
			hex_leds[2] = hex_leds_char_O;
			hex_leds[1] = hex_leds_char_S;
			hex_leds[0] = hex_leds_char_E;
		end
	endcase
	
	for (int sw_idx = 0; sw_idx < 10; ++sw_idx) begin
		sw_leds[sw_idx] = (obstacles_sw[sw_idx] != OBSTACLE_NONE);
	end
end

// --------------------------------------------------------------------------------

endmodule: BGoralcGame

`default_nettype wire
