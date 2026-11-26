/*
 * Julian Lashbrook's Game
 */

`default_nettype none

module JLashbrGame
(
	input logic
	key0,  // upper button
	key1,  // lower button
	clock_50MHz,
	reset,
	
	output logic [5:0] [7:0]
	hex_leds,
	
	output logic [9:0]
	sw_leds
);

HexNibbleDisplayDriver DIGIT(4'h2, hex_leds[0]);

endmodule: JLashbrGame

`default_nettype wire
