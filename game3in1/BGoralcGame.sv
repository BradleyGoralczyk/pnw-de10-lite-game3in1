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

parameter int CLOCK_OBSTACLES_DIVISOR_START = 50_000_000 / 8;
parameter int CLOCK_OBSTACLES_DIVISOR_END = 50_000_000 / 16;
// It should take 60.03125 seconds to double the speed.
// Proof: sum {from k=0 to 640-1} (1 / 8 - k / 16 / 640)
parameter int CLOCK_OBSTACLES_DIVISOR_STEP = (CLOCK_OBSTACLES_DIVISOR_START - CLOCK_OBSTACLES_DIVISOR_END) / 640;

parameter int CLOCK_FLASHING_DIVISOR = 50_000_000 / 2;

// --------------------------------------------------------------------------------
// Submodule Instantiation
// --------------------------------------------------------------------------------

logic [$clog2(CLOCK_OBSTACLES_DIVISOR_START)-1:0] clock_obstacles_divisor;
logic clock_obstacles;
ClockDividerN #( .WIDTH ($bits(clock_obstacles_divisor)) ) CLOCK_OBSTACLES
(
	.clock_in (clock_50MHz),
	.reset (game_state != GAME_PLAY),
	.divisor (clock_obstacles_divisor),
	.clock_out (clock_obstacles)
);

logic clock_flashing;
ClockDividerN CLOCK_FLASHING
(
	.clock_in (clock_50MHz),
	.reset (game_state != GAME_LOSE),
	.divisor (CLOCK_FLASHING_DIVISOR),
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

logic [3:0] [3:0] curr_score;
CounterBCD CURR_SCORE
(
	.clock (clock_obstacles),
	.reset (reset_obstacles),
	.value (curr_score)
);

logic [3:0] [3:0] high_score;
logic [3:0] [7:0] hex_leds_high_score;
HexNibbleDisplayDriver HIGH_SCORE_THOUSANDS
(
	.nibble (high_score[3]),
	.leds (hex_leds_high_score[3])
);
HexNibbleDisplayDriver HIGH_SCORE_HUNDREDS
(
	.nibble (high_score[2]),
	.leds (hex_leds_high_score[2])
);
HexNibbleDisplayDriver HIGH_SCORE_TENS
(
	.nibble (high_score[1]),
	.leds (hex_leds_high_score[1])
);
HexNibbleDisplayDriver HIGH_SCORE_ONES
(
	.nibble (high_score[0]),
	.leds (hex_leds_high_score[0])
);

// --------------------------------------------------------------------------------
// Obstacle Generator
// --------------------------------------------------------------------------------

ObstacleState obstacles [15:0];
ObstacleState next_obstacle;
always_comb begin
	case (obstacles[0])
		default: begin  // OBSTACLE_NONE, but technically the enum has a fourth (invalid) state so SystemVerilog was throwing a fit.
			if (obstacles[1] != OBSTACLE_NONE) begin
				// One-wide gaps are really hard to navigate.
				next_obstacle = OBSTACLE_NONE;
			end else if (rng_value_obstacles > 32'h20000000) begin
				next_obstacle = OBSTACLE_NONE;
			end else if (rng_value_obstacles > 32'h10000000) begin
				next_obstacle = OBSTACLE_BIRD;
			end else begin
				next_obstacle = OBSTACLE_BUSH;
			end
		end
		OBSTACLE_BIRD,
		OBSTACLE_BUSH: begin
			if (rng_value_obstacles > 32'h40000000) begin
				// Guaranteed to produce a gap before switching between bird and bush.
				next_obstacle = OBSTACLE_NONE;
			end else begin
				next_obstacle = obstacles[0];
			end
		end
	endcase
end

logic reset_obstacles;
always_ff @(posedge clock_obstacles or posedge reset_obstacles) begin
	if (reset_obstacles) begin
		for (int i = 0; i < 16; ++i) begin
			obstacles[i] <= OBSTACLE_NONE;
		end
		clock_obstacles_divisor <= CLOCK_OBSTACLES_DIVISOR_START;
	end else begin
		for (int i = 1; i < 16; ++i) begin
			obstacles[i] <= obstacles[i - 1];
		end
		obstacles[0] <= next_obstacle;
		if (clock_obstacles_divisor <= CLOCK_OBSTACLES_DIVISOR_END) begin
			clock_obstacles_divisor <= CLOCK_OBSTACLES_DIVISOR_END;
		end else begin
			clock_obstacles_divisor <= clock_obstacles_divisor - CLOCK_OBSTACLES_DIVISOR_STEP;
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
		high_score <= 16'h0000;
	end else begin
		case (game_state)
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
		if (curr_score > high_score) begin
			high_score <= curr_score;
		end else begin
			high_score <= high_score;
		end
	end
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
			hex_leds[3] = hex_leds_high_score[3];
			hex_leds[2] = hex_leds_high_score[2];
			hex_leds[1] = hex_leds_high_score[1];
			hex_leds[0] = hex_leds_high_score[0];
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
