module LinearCongruentialRNGTest
(
	input logic
	clock,
	reset,
	
	output logic [31:0]
	value
);

LinearCongruentialRNG TEST
(
	.clock (clock),
	.reset (reset),
	.value (value)
);

endmodule: LinearCongruentialRNGTest
