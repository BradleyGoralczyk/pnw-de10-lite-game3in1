/*
 * Bradley Goralczyk's Game
 * Inspired by Google Chrome's Dinosaur Run Game
 */

`default_nettype none

module BGoralcGame
import BGoralcGameObstacleGen_pkg::*;
(
	input logic
	key0,  // upper button (jump)
	key1,  // lower button (duck)
	clock_50MHz,
	
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
	.reset (0),
	.divisor (DIVISOR_BIRDBUSH_MAX),
	.clock_out (clock_birdbush)
);

BGoralcGameObstacleState obstacles [15:0];
BGoralcGameObstacleGen GEN_BIRDBUSH
(
	.clock (clock_birdbush),
	.reset (0),
	.obstacles(obstacles)
);

// --------------------------------------------------------------------------------

DinoState curr_dino_state;
DinoState next_dino_state;

always_comb begin
	// TODO: Jump should be on positive edge and on a timer, not a hold like duck.
	case (curr_dino_state)
	DINO_WALK: begin
		if (key0)      next_dino_state = DINO_JUMP;
		else if (key1) next_dino_state = DINO_DUCK;
		else           next_dino_state = DINO_WALK;
	end
	DINO_JUMP: begin
		if (key0)      next_dino_state = DINO_JUMP;
		else           next_dino_state = DINO_WALK;
	end
	DINO_DUCK: begin
		if (key1)      next_dino_state = DINO_DUCK;
		else           next_dino_state = DINO_WALK;
	end
	default: begin
		               next_dino_state = DINO_WALK;
	end
	endcase
end

always_ff @(posedge clock_50MHz) begin
	if (0 /* reset */) begin
		curr_dino_state = DINO_WALK;
	end else begin
		curr_dino_state = next_dino_state;
	end
end

// --------------------------------------------------------------------------------

always_comb begin
	// Dino display driver
	hex_leds[5][4] = curr_dino_state == DINO_WALK | curr_dino_state == DINO_DUCK;
	hex_leds[5][5] = curr_dino_state == DINO_WALK | curr_dino_state == DINO_JUMP;
	
	// Obstacle display driver
	for (int hex_idx = 0; hex_idx < 6; ++hex_idx) begin
		hex_leds[hex_idx][0] = obstacles[hex_idx + 10] == OBSTACLE_BIRD;
		hex_leds[hex_idx][3] = obstacles[hex_idx + 10] == OBSTACLE_BUSH;
	end
	for (int sw_idx = 0; sw_idx < 10; ++sw_idx) begin
		sw_leds[sw_idx] = obstacles[sw_idx] != OBSTACLE_NONE;
	end
end

// --------------------------------------------------------------------------------

endmodule: BGoralcGame

`default_nettype wire
