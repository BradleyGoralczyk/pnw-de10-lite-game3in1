/*
 * I spent a couple hours trying to make this myself.
 * Google Gemini made it in two seconds.
 * Max divisor = (2 ^ WIDTH) - 1.  WIDTH = 32 by default.
 */

`default_nettype none

module ClockDividerN #(parameter int WIDTH = 32)
(
	input logic
	clock_in,
	reset,
	
	input logic [WIDTH-1:0]
	divisor,  // Dynamic division factor (values < 1 treated as 1)
	
	output logic
	clock_out
);

logic [WIDTH-1:0] divisor_safe, counter_pos, counter_neg;
logic clock_pos, clock_neg;

// Guard against divisor == 0 by clamping minimum divisor to 1.
assign divisor_safe = (divisor == '0) ? WIDTH'(1) : divisor;

// Positive-edge counter
always_ff @(posedge clock_in or posedge reset) begin
	if (reset) begin
		counter_pos <= '0;
		clock_pos <= 1'b0;
	end else begin
		if (counter_pos >= (divisor_safe - 1'b1)) begin
			counter_pos <= '0;
			clock_pos <= (divisor_safe > WIDTH'(1)); // Start high for new cycle if N > 1
		end else begin
			counter_pos <= counter_pos + 1'b1;
			clock_pos <= ((counter_pos + 1'b1) < (divisor_safe >> 1));
		end
	end
end

// Negative-edge counter (tracks divisor_safe half a cycle later)
always_ff @(negedge clock_in or posedge reset) begin
	if (reset) begin
		counter_neg <= '0;
		clock_neg <= 1'b0;
	end else begin
		if (counter_neg >= (divisor_safe - 1'b1)) begin
			counter_neg <= '0;
			clock_neg <= (divisor_safe > WIDTH'(1));
		end else begin
			counter_neg <= counter_neg + 1'b1;
			clock_neg <= ((counter_neg + 1'b1) < (divisor_safe >> 1));
		end
	end
end

// Select output mode based on active divisor
always_comb begin
	if (divisor_safe == WIDTH'(1)) begin
		// Identity
		clock_out = clock_in;
	end else if (divisor_safe[0] == 1'b0) begin
		// Even divisor
		clock_out = clock_pos;
	end else begin
		// Odd divisor     
		clock_out = clock_pos | clock_neg;
	end
end

endmodule

`default_nettype wire
