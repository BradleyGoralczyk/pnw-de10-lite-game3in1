/*
 * Hexadecimal Nibble Display Driver (Active-High)
 */

module HexNibbleDisplayDriver
(
	input logic [3:0]
	nibble,
	
	output logic [7:0]
	leds
);

logic [7:0] result;
always_comb begin
	case (nibble)
		4'h0: result = 8'b00111111;
		4'h1: result = 8'b00000110;
		4'h2: result = 8'b01011011;
		4'h3: result = 8'b01001111;
		4'h4: result = 8'b01100110;
		4'h5: result = 8'b01101101;
		4'h6: result = 8'b01111101;
		4'h7: result = 8'b00000111;
		4'h8: result = 8'b01111111;
		4'h9: result = 8'b01101111;
		4'hA: result = 8'b01110111;
		4'hB: result = 8'b01111100;
		4'hC: result = 8'b00111001;
		4'hD: result = 8'b01011110;
		4'hE: result = 8'b01111001;
		4'hF: result = 8'b01110001;
	endcase
end
assign leds = result;

endmodule: HexNibbleDisplayDriver
