module CounterBCDTest
(
	input logic
	clock,
	reset,
	
	output logic [3:0]
	value1000,
	value100,
	value10,
	value1
);

logic [3:0] [3:0] value;

CounterBCD TEST
(
	.clock (clock),
	.reset (reset),
	.value (value)
);

assign value1000 = value[3];
assign value100 = value[2];
assign value10 = value[1];
assign value1 = value[0];

endmodule: CounterBCDTest
