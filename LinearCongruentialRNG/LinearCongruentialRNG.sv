/*
 * Linear Congruential Random Number Generator (LCG)
 * Thanks MetroWerks!
 */

module LinearCongruentialRNG
(
	input logic
	clock,
	reset,
	
	output logic [31:0]
	value
);

wire logic [31:0] next;

always_ff @(posedge clock or posedge reset) begin
	if (reset) begin
		next = 0;
	end else begin
		next = next * 1103515245 + 12345;
	end
end

assign value = next;

endmodule: LinearCongruentialRNG
