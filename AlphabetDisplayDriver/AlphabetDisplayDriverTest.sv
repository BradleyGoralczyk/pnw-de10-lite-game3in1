module AlphabetDisplayDriverTest
import AlphabetDisplayDriver_pkg::*;
(
	input logic [4:0]
	sws,
	
	output logic [7:0]
	hex_leds
);

AlphabetDisplayDriverChar char;
assign char = AlphabetDisplayDriverChar'(sws);

logic [7:0] hex_leds_hi;
AlphabetDisplayDriver DRIVER
(
	.char (char),
	.leds (hex_leds_hi)
);
assign hex_leds = ~hex_leds_hi;

endmodule: AlphabetDisplayDriverTest
