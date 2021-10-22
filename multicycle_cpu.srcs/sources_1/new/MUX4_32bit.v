`timescale 1ns / 1ps
module MUX4_32(
	input [1:0]ctrl,
	input [31:0] in00,
	input [31:0] in01,
	input [31:0] in10,
	input [31:0] in11,
	output [31:0] out
);
	assign out = ctrl[0] ? (ctrl[1] ? in11 : in01) : (ctrl[1] ? in10 : in00);
endmodule