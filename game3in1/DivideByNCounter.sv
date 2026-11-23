module DivideByNCounter #(parameter N)
(
	input logic
	clock_50MHz,
	reset,
	
	output logic
	clock
);

wire logic [31:0] count;
wire logic clock_internal;

always_ff @(posedge clock or posedge reset) begin
	if (reset == 1) begin
		count <= 0;
		clock_internal <= 0;
	end else if (count == N) begin
		count <= 0;
		clock_internal <= ~clock_internal;
	end else begin
		count <= count + 1;
	end
end

assign clock = clock_internal;

endmodule: DivideByNCounter
