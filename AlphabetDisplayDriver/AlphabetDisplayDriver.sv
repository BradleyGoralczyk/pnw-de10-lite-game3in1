/*
 * Alphabet Display Driver
 * Not all letters look great on a 7-segment display.
 * A few letters that look good in both lowercase and uppercase support both.
 */

package AlphabetDisplayDriver_pkg;

typedef enum logic [4:0] {
	ALPHA_A,
	ALPHA_B,
	ALPHA_C,
	ALPHA_D,
	ALPHA_E,
	ALPHA_F,
	ALPHA_G,
	ALPHA_H,
	ALPHA_I,
	ALPHA_J,
	ALPHA_K,
	ALPHA_L,
	ALPHA_M,
	ALPHA_N,
	ALPHA_O,
	ALPHA_P,
	ALPHA_Q,
	ALPHA_R,
	ALPHA_S,
	ALPHA_T,
	ALPHA_U,
	ALPHA_V,
	ALPHA_W,
	ALPHA_X,
	ALPHA_Y,
	ALPHA_Z,
	ALPHA_h,
	ALPHA_o,
	ALPHA_u,
	ALPHA_v,
	ALPHA_EXCLAMATION
} AlphabetDisplayDriverChar;

endpackage: AlphabetDisplayDriver_pkg

module AlphabetDisplayDriver
import AlphabetDisplayDriver_pkg::*;
(
	input AlphabetDisplayDriverChar
	char,
	
	output logic [7:0]
	leds
);

logic [7:0] result;
always_comb begin
	case (char)
		ALPHA_A: result <= 8'b01110111;
		ALPHA_B: result <= 8'b01111100;
		ALPHA_C: result <= 8'b00111001;
		ALPHA_D: result <= 8'b01011110;
		ALPHA_E: result <= 8'b01111001;
		ALPHA_F: result <= 8'b01110001;
		ALPHA_G: result <= 8'b00111101;
		ALPHA_H: result <= 8'b01110110;
		ALPHA_I: result <= 8'b00000110;
		ALPHA_J: result <= 8'b00011110;
		ALPHA_K: result <= 8'b01111010;
		ALPHA_L: result <= 8'b00111000;
		ALPHA_M: result <= 8'b01010101;
		ALPHA_N: result <= 8'b01010100;
		ALPHA_O: result <= 8'b00111111;
		ALPHA_P: result <= 8'b01110011;
		ALPHA_Q: result <= 8'b01100111;
		ALPHA_R: result <= 8'b01010000;
		ALPHA_S: result <= 8'b01101101;
		ALPHA_T: result <= 8'b01111000;
		ALPHA_U: result <= 8'b00111110;
		ALPHA_V: result <= 8'b00111110;
		ALPHA_W: result <= 8'b01101010;
		ALPHA_X: result <= 8'b00010100;
		ALPHA_Y: result <= 8'b01101110;
		ALPHA_Z: result <= 8'b01011011;
		ALPHA_h: result <= 8'b01110100;
		ALPHA_o: result <= 8'b01011100;
		ALPHA_u: result <= 8'b00011100;
		ALPHA_v: result <= 8'b00011100;
		ALPHA_EXCLAMATION: result <= 8'b10000010;
		default: result <= 8'b00000000;  // Gets optimized away and behaves wrong.  Whatever.
	endcase
end
assign leds = result;

endmodule: AlphabetDisplayDriver
