module LevelToPulseTest
(
	input logic
	level,
	clock,
	
	output logic
	pulse
);

LevelToPulse TEST
(
	.level (level),
	.clock (clock),
	.pulse (pulse)
);

endmodule: LevelToPulseTest
