/*
 * Dummy Game
 * This game does nothing and displays nothing.
 */

`default_nettype none

module DummyGame
(
	input logic
	key0,  // Upper button
	key1,  // Lower button
	clock_50MHz,
	
	output logic [5:0] [7:0]
	hex_leds,
	
	output logic [9:0]
	sw_leds
);

// --------------------------------------------------------------------------------

always_comb begin
	for (int i = 0; i < 6; ++i) begin
		hex_leds[i] = 8'b00000000;
	end
	sw_leds = 10'b0000000000;
end

// --------------------------------------------------------------------------------

endmodule: DummyGame

`default_nettype wire
