module ClockDividerNTest
(
	input logic
	clock_source,
	reset,
	
	output logic
	clock_div_a,
	clock_div_b,
	clock_div_c
);

ClockDividerN DIV_A
(
	.clock_in (clock_source),
	.reset (reset),
	.divisor (1),
	.clock_out (clock_div_a)
);

ClockDividerN DIV_B
(
	.clock_in (clock_source),
	.reset (reset),
	.divisor (3),
	.clock_out (clock_div_b)
);

ClockDividerN DIV_C
(
	.clock_in (clock_source),
	.reset (reset),
	.divisor (4),
	.clock_out (clock_div_c)
);

endmodule: ClockDividerNTest
