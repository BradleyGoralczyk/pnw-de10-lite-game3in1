/*
 * Sample Game
 * Random number generator scramble showcase!
 * Press key0 to pause.  Press key1 to reset.
 */

`default_nettype none

module SampleGame
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

// --------------------------------------------------------------------------------

// Sample down to a slower clock.
logic clock;
ClockDividerN CLOCK_DIV
(
	.clock_in (clock_50MHz),
	.reset (key0),
	.divisor (50 * 1000 * 1000 / 8),
	.clock_out (clock)
);

// Random Number Generator
logic [31:0] rng_value;
LinearCongruentialRNG LCRNG
(
	// Input
	.clock (clock),
	.reset (key1),
	// Output
	.value (rng_value)
);

// --------------------------------------------------------------------------------

// Assign the nibbles.
logic [7:0] [3:0] digit_value;  // 8 nibbles for a 32-bit value.
always_comb begin
	for (int nibble = 0; nibble < 8; ++nibble) begin
		// Indexed Part-Select Operator (+: or -:) because
		// System Verilog doesn't like a variable being in
		// both bounds of a bit slice.
		digit_value[nibble] = rng_value[nibble*4 +: 4];
	end
	// Turn off all of the switch LEDs; this demo doesn't use them.
	sw_leds = 10'b0000000000;
end

// Hook up the nibbles of the random value to the hex leds with a driver.
genvar digitIdx;
generate
	for (digitIdx = 0; digitIdx < 6; ++digitIdx) begin : HEX_DISPLAY
		HexNibbleDisplayDriver DIGIT(digit_value[digitIdx], hex_leds[digitIdx]);
	end
endgenerate

// --------------------------------------------------------------------------------

endmodule: SampleGame

`default_nettype wire
