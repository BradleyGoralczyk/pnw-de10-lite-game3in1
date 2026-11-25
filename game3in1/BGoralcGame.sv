/*
 * Bradley Goralczyk's Game
 */

`default_nettype none

module BGoralcGame
(
	input logic
	key0,  // upper button
	key1,  // lower button
	clock_50MHz,
	
	output logic [5:0] [7:0]
	hex_leds,
	
	output logic [9:0]
	sw_leds
);

HexNibbleDisplayDriver DIGIT(4'h1, hex_leds[0]);

endmodule: BGoralcGame

`default_nettype wire
