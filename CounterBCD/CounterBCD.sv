module CounterBCD
(
	input logic
	clock,
	reset,
	
	output logic [3:0] [3:0]
	value
);

always_ff @(posedge clock or posedge reset) begin
	if (reset) begin
		value = 16'h0000;
	end else if (value != 16'h9999) begin
		if (value[0] == 4'd9) begin
			value[0] <= 4'd0;
			if (value[1] == 4'd9) begin
				value[1] <= 4'd0;
				if (value[2] == 4'd9) begin
					value[2] <= 4'd0;
					if (value[3] == 4'd9) begin
						// Do nothing
					end else begin
						value[3] <= value[3] + 4'd1;
					end
				end else begin
					value[2] <= value[2] + 4'd1;
				end	
			end else begin
				value[1] <= value[1] + 4'd1;
			end
		end else begin
			value[0] <= value[0] + 4'd1;
		end
	end
end

endmodule: CounterBCD
