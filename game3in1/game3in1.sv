/*
 * Introduction To Digital System Design Final Project
 * 3 Games In 1
 * Bradley Goralczyk, Julian Lashbrook, Andrew Ciastko
 */

`default_nettype none

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
DummyGame DUMMYGAME
(
	.hex_leds (dummy_hex_leds),
	.sw_leds (dummy_sw_leds)
);

logic sample_enable;
logic [5:0] [7:0] sample_hex_leds;
logic [9:0] sample_sw_leds;
SampleGame SAMPLEGAME
(
	.key0 (sample_enable ? key0 : 0),
	.key1 (sample_enable ? key1 : 0),
	.clock_50MHz (sample_enable ? clock_50MHz : 0),
	.hex_leds (sample_hex_leds),
	.sw_leds (sample_sw_leds)
);

logic bgoralc_enable;
logic [5:0] [7:0] bgoralc_hex_leds;
logic [9:0] bgoralc_sw_leds;
BGoralcGame BGORALCGAME
(
	.key0 (bgoralc_enable ? key0 : 0),
	.key1 (bgoralc_enable ? key1 : 0),
	.clock_50MHz (bgoralc_enable ? clock_50MHz : 0),
	.hex_leds (bgoralc_hex_leds),
	.sw_leds (bgoralc_sw_leds)
);

logic jlashbr_enable;
logic [5:0] [7:0] jlashbr_hex_leds;
logic [9:0] jlashbr_sw_leds;
JLashbrGame JLASHBRGAME
(
	.key0 (jlashbr_enable ? key0 : 0),
	.key1 (jlashbr_enable ? key1 : 0),
	.clock_50MHz (jlashbr_enable ? clock_50MHz : 0),
	.hex_leds (jlashbr_hex_leds),
	.sw_leds (jlashbr_sw_leds)
);

logic aciastk_enable;
logic [5:0] [7:0] aciastk_hex_leds;
logic [9:0] aciastk_sw_leds;
ACiastkGame ACIASTKGAME
(
	.key0 (aciastk_enable ? key0 : 0),
	.key1 (aciastk_enable ? key1 : 0),
	.clock_50MHz (aciastk_enable ? clock_50MHz : 0),
	.hex_leds (aciastk_hex_leds),
	.sw_leds (aciastk_sw_leds)
);

// --------------------------------------------------------------------------------

// Game enabler
always_comb begin
	sample_enable = (sw == 0);
	bgoralc_enable = (sw == 1);
	jlashbr_enable = (sw == 2);
	aciastk_enable = (sw == 3);
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
			hex_leds <= ~sample_hex_leds;
			sw_leds <= sample_sw_leds;
		end
		1: begin
			hex_leds <= ~bgoralc_hex_leds;
			sw_leds <= bgoralc_sw_leds;
		end
		2: begin
			hex_leds <= ~jlashbr_hex_leds;
			sw_leds <= jlashbr_sw_leds;
		end
		3: begin
			hex_leds <= ~aciastk_hex_leds;
			sw_leds <= aciastk_sw_leds;
		end
	endcase
end

// --------------------------------------------------------------------------------

endmodule: game3in1

`default_nettype wire
