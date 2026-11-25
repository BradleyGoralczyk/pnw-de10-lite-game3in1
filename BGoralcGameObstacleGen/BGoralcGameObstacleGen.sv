
package BGoralcGameObstacleGen_pkg;

typedef enum logic [1:0]
{
	OBSTACLE_NONE = 2'b00,
	OBSTACLE_BIRD = 2'b01,
	OBSTACLE_BUSH = 2'b10
} BGoralcGameObstacleState;

endpackage: BGoralcGameObstacleGen_pkg

module BGoralcGameObstacleGen
import BGoralcGameObstacleGen_pkg::*;
#(parameter int buffer_size = 16)
(
	input logic
	clock,
	reset,
	
	output BGoralcGameObstacleState
	obstacles [buffer_size - 1:0]
);

logic [31:0] rng_value;
LinearCongruentialRNG LCRNG
(
	// Input
	.clock (clock),
	.reset (0),
	// Output
	.value (rng_value)
);

always_ff @(posedge clock or posedge reset) begin
	if (reset) begin
		for (int i = 0; i < buffer_size; ++i) begin
			obstacles[i] <= OBSTACLE_NONE;
		end
	end else begin
		for (int i = 1; i < buffer_size; ++i) begin
			obstacles[i] <= obstacles[i - 1];
		end
		// TODO: Don't generate impossible patterns
		if (rng_value > 32'h20000000) begin
			obstacles[0] <= OBSTACLE_NONE;
		end else if (rng_value > 32'h10000000) begin
			obstacles[0] <= OBSTACLE_BIRD;
		end else begin
			obstacles[0] <= OBSTACLE_BUSH;
		end
	end
end

endmodule: BGoralcGameObstacleGen
