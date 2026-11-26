/*
 * Bradley Goralczyk's Game
 * Inspired by Google Chrome's Dinosaur Run Game
 */

`default_nettype none

module BGoralcGame
import BGoralcGameObstacleGen_pkg::*, AlphabetDisplayDriver_pkg::*;
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

parameter int DIVISOR_BIRDBUSH_MIN = 50 * 1000 * 1000 / 1;
parameter int DIVISOR_BIRDBUSH_MAX = 50 * 1000 * 1000 / 8;

// --------------------------------------------------------------------------------
// Submodule Instantiation
// --------------------------------------------------------------------------------

logic clock_birdbush, clock_birdbush_divisor;
ClockDividerN CLOCK_BIRDBUSH
(
	.clock_in (clock_50MHz),
	.reset (game_state != GAME_PLAY),
	.divisor (DIVISOR_BIRDBUSH_MAX),
	.clock_out (clock_birdbush)
);

logic clock_flashing;
ClockDividerN CLOCK_FLASHING
(
	.clock_in (clock_50MHz),
	.reset (game_state != GAME_LOSE),
	.divisor (50 * 1000 * 1000 / 2),
	.clock_out (clock_flashing)
);

logic obstacle_gen_reset;
BGoralcGameObstacleState obstacles [15:0];
BGoralcGameObstacleGen GEN_BIRDBUSH
(
	.clock (clock_birdbush),
	.reset (obstacle_gen_reset),
	.obstacles(obstacles)
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
// Game Main Loop
// --------------------------------------------------------------------------------

GameState game_state;
DinoState dino_state;
always_ff @(posedge clock_50MHz or posedge reset) begin
	if (reset) begin
		dino_state <= DINO_WALK;
		game_state <= GAME_TITLE;
		obstacle_gen_reset <= 1'b1;
	end else	case (game_state)
		GAME_TITLE: begin
			dino_state <= DINO_WALK;
			game_state <= anykey_pulse ? GAME_PLAY : game_state;
			obstacle_gen_reset <= 1'b1;
		end
		GAME_LOSE: begin
			dino_state <= dino_state;
			game_state <= anykey_pulse ? GAME_TITLE : game_state;
			obstacle_gen_reset <= 1'b0;
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
			obstacle_gen_reset <= 1'b0;
		end
	endcase
end

// --------------------------------------------------------------------------------
// Display Driver
// --------------------------------------------------------------------------------

logic show_obstacles;
always_comb begin
	// Overcommit to avoid inferred latches and output ports with no driver.
	for (int hex_idx = 0; hex_idx < 6; ++hex_idx) begin
		hex_leds[hex_idx] = 8'b00000000;
	end
	
	hex_leds[5][4] = (dino_state == DINO_WALK | dino_state == DINO_DUCK);
	hex_leds[5][5] = (dino_state == DINO_WALK | dino_state == DINO_JUMP);
	show_obstacles = (game_state == GAME_PLAY || clock_flashing);
	for (int hex_idx = 0; hex_idx < 6; ++hex_idx) begin
		hex_leds[hex_idx][0] = (obstacles[hex_idx + 10] == OBSTACLE_BIRD) && show_obstacles;
		hex_leds[hex_idx][3] = (obstacles[hex_idx + 10] == OBSTACLE_BUSH) && show_obstacles;
	end
	case (game_state)
		GAME_TITLE: begin
			hex_leds[3] = hex_leds_char_r;
			hex_leds[2] = hex_leds_char_u;
			hex_leds[1] = hex_leds_char_n;
			hex_leds[0] = hex_leds_char_exclamation;
		end
		GAME_LOSE: begin
			hex_leds[3] = hex_leds_char_L;
			hex_leds[2] = hex_leds_char_O;
			hex_leds[1] = hex_leds_char_S;
			hex_leds[0] = hex_leds_char_E;
		end
	endcase
	
	for (int sw_idx = 0; sw_idx < 10; ++sw_idx) begin
		sw_leds[sw_idx] = (obstacles[sw_idx] != OBSTACLE_NONE);
	end
end

// --------------------------------------------------------------------------------

endmodule: BGoralcGame

`default_nettype wire
