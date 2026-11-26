module LevelToPulse
(
	input logic
	level,
	clock,
	
	output logic
	pulse
);

logic level_buffer_0, level_buffer_1;

always_ff @(posedge clock) begin
	level_buffer_0 <= level;
	level_buffer_1 <= level_buffer_0;
end

assign pulse = level_buffer_0 && !level_buffer_1;

endmodule: LevelToPulse
