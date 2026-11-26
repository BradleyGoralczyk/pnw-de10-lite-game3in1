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

typedef enum logic [1:0]
{
	DINO_WALK,
	DINO_JUMP,
	DINO_DUCK
} DinoState;

parameter int DIVISOR_BIRDBUSH_MIN = 50 * 1000 * 1000 / 1;
parameter int DIVISOR_BIRDBUSH_MAX = 50 * 1000 * 1000 / 8;

// --------------------------------------------------------------------------------

logic clock_birdbush, clock_birdbush_divisor;
ClockDividerN CLOCK_BIRDBUSH
(
	.clock_in (clock_50MHz),
	.reset (dino_is_dead),
	.divisor (DIVISOR_BIRDBUSH_MAX),
	.clock_out (clock_birdbush)
);

logic clock_flashing;
ClockDividerN CLOCK_FLASHING
(
	.clock_in (clock_50MHz),
	.reset (!dino_is_dead),
	.divisor (50 * 1000 * 1000 / 2),
	.clock_out (clock_flashing)
);

BGoralcGameObstacleState obstacles [15:0];
BGoralcGameObstacleGen GEN_BIRDBUSH
(
	.clock (clock_birdbush),
	.reset (0),
	.obstacles(obstacles)
);

logic [7:0] hex_leds_char_L, hex_leds_char_O, hex_leds_char_S, hex_leds_char_E;
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

// --------------------------------------------------------------------------------

logic dino_is_dead;
DinoState dino_state;
always_ff @(posedge clock_50MHz) begin
	case (obstacles[15])  // Displayed on HEX5
		OBSTACLE_BIRD: if (dino_state == DINO_JUMP || dino_state == DINO_WALK) begin
			dino_is_dead <= 1'b1;
		end
		OBSTACLE_BUSH: if (dino_state == DINO_DUCK || dino_state == DINO_WALK) begin
			dino_is_dead <= 1'b1;
		end
		default: begin
			dino_is_dead <= 1'b0;
		end
	endcase
	
	if (dino_is_dead) begin
		dino_state <= dino_state;
	end else	if (key0 && !key1) begin
		dino_state <= DINO_JUMP;
	end else if (!key0 && key1) begin
		dino_state <= DINO_DUCK;
	end else begin
		dino_state <= DINO_WALK;
	end
end

// --------------------------------------------------------------------------------

// Display Driver
logic show_obstacles;
always_comb begin
	hex_leds[5][4] = (dino_state == DINO_WALK | dino_state == DINO_DUCK);
	hex_leds[5][5] = (dino_state == DINO_WALK | dino_state == DINO_JUMP);
	
	// Overcommit HEX3-HEX0 to avoid inferred latches.
	hex_leds[3] = 8'b00000000;
	hex_leds[2] = 8'b00000000;
	hex_leds[1] = 8'b00000000;
	hex_leds[0] = 8'b00000000;
	show_obstacles = (!dino_is_dead || clock_flashing);
	for (int hex_idx = 0; hex_idx < 6; ++hex_idx) begin
		hex_leds[hex_idx][0] = (obstacles[hex_idx + 10] == OBSTACLE_BIRD) && show_obstacles;
		hex_leds[hex_idx][3] = (obstacles[hex_idx + 10] == OBSTACLE_BUSH) && show_obstacles;
	end
	if (dino_is_dead) begin
		hex_leds[3] = hex_leds_char_L;
		hex_leds[2] = hex_leds_char_O;
		hex_leds[1] = hex_leds_char_S;
		hex_leds[0] = hex_leds_char_E;
	end
	
	for (int sw_idx = 0; sw_idx < 10; ++sw_idx) begin
		sw_leds[sw_idx] = (obstacles[sw_idx] != OBSTACLE_NONE);
	end
end

// --------------------------------------------------------------------------------

endmodule: BGoralcGame

`default_nettype wire
