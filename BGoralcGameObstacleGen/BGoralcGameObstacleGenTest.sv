module BGoralcGameObstacleGenTest
import BGoralcGameObstacleGen_pkg::*;
(
	input logic
	clock,
	reset,
	
	// Standard VCD files only natively support simple 1-bit or 1D bit-vector types (logic, reg, wire, bit).
	// High-level SystemVerilog constructs, such as enum types, structs, or multidimensional/unpacked arrays,
	// are frequently omitted from VCD dumps.
	// Fix: Cast or assign your enum or struct signals to a plain logic [N-1:0] vector at the top level of
	// your testbench or wrapper module so the VCD dumper can record them, or switch to a native waveform format
	// (like .wlf in Questa) instead of VCD.
	output logic [1:0]
	obstacles_primitive_0,
	obstacles_primitive_1,
	obstacles_primitive_2,
	obstacles_primitive_3,
	obstacles_primitive_4,
	obstacles_primitive_5,
	obstacles_primitive_6,
	obstacles_primitive_7,
	obstacles_primitive_8,
	obstacles_primitive_9,
	obstacles_primitive_10,
	obstacles_primitive_11,
	obstacles_primitive_12,
	obstacles_primitive_13,
	obstacles_primitive_14,
	obstacles_primitive_15
);

BGoralcGameObstacleState obstacles [15:0];

BGoralcGameObstacleGen GEN
(
	.clock (clock),
	.reset (reset),
	.obstacles (obstacles)
);

always_comb begin
	obstacles_primitive_0 = obstacles[0];
	obstacles_primitive_1 = obstacles[1];
	obstacles_primitive_2 = obstacles[2];
	obstacles_primitive_3 = obstacles[3];
	obstacles_primitive_4 = obstacles[4];
	obstacles_primitive_5 = obstacles[5];
	obstacles_primitive_6 = obstacles[6];
	obstacles_primitive_7 = obstacles[7];
	obstacles_primitive_8 = obstacles[8];
	obstacles_primitive_9 = obstacles[9];
	obstacles_primitive_10 = obstacles[10];
	obstacles_primitive_11 = obstacles[11];
	obstacles_primitive_12 = obstacles[12];
	obstacles_primitive_13 = obstacles[13];
	obstacles_primitive_14 = obstacles[14];
	obstacles_primitive_15 = obstacles[15];
end

endmodule: BGoralcGameObstacleGenTest
