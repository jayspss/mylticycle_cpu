`timescale 1ns / 1ps
module MUX2_32(
	input ctrl,
	input [31:0] in0,
	input [31:0] in1,
	output [31:0] out
);
	assign out = ctrl ? in1 : in0;
endmodule