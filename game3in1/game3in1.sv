/*
 * Introduction To Digital System Design Final Project
 * 3 Games In 1
 * Bradley Goralczyk, Julian Lashbrook, Andrew Ciastko
 */

module game3in1
(
	input logic
	key0_low,  // Upper button
	key1_low,  // Lower button
	clock_50MHz,  // 50 MHz clock input
	
	input logic [9:0]
	sw,  // Switches
	
	output logic [5:0] [7:0]
	hex_leds,  // 7-Segment Displays (plus decimal point)
	
	output logic [9:0]
	sw_leds  // Red LEDS above switches
);

// --------------------------------------------------------------------------------

// key0 and key1 must be active HIGH for the games.
logic key0, key1;
assign key0 = ~key0_low;
assign key1 = ~key1_low;

// --------------------------------------------------------------------------------

logic [5:0] [7:0] dummy_hex_leds;
logic [9:0] dummy_sw_leds;
DummyGame DUMMY
(
	.hex_leds (dummy_hex_leds),
	.sw_leds (dummy_sw_leds)
);

// --------------------------------------------------------------------------------

logic game0_enable;
logic [5:0] [7:0] game0_hex_leds;
logic [9:0] game0_sw_leds;
SampleGame GAME0
(
	.key0 (game0_enable ? key0 : 0),
	.key1 (game0_enable ? key1 : 0),
	.clock_50MHz (game0_enable ? clock_50MHz : 0),
	.hex_leds (game0_hex_leds),
	.sw_leds (game0_sw_leds)
);

// --------------------------------------------------------------------------------

// Game enabler
always_comb begin
	game0_enable = (sw == 0);
end

// Display selector
always_comb begin
	// hex_leds is active LOW, but the games use active HIGH.
	case (sw)
		default: begin
			hex_leds <= ~dummy_hex_leds;
			sw_leds <= dummy_sw_leds;
		end
		0: begin
			hex_leds <= ~game0_hex_leds;
			sw_leds <= game0_sw_leds;
		end
	endcase
end

// --------------------------------------------------------------------------------

endmodule: game3in1
