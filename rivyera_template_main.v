`timescale 1ns / 1ps

`include "SciEngines_API_constant.v"

module rivyera_template_main (
	//
	// API PORTS
	//
		// GENERAL PORTS
		input								api_clk_in,
		input								api_rst_in,
		output	[`C_NUM_LEDS-1:0]			api_led_out,
		input	[`C_LENGTH_HW_REV-1:0]		api_hw_rev_in,
		// ADDRESS PORTS
		input								api_self_contr_in,
		input	[`C_LENGTH_ADDR_SLOT-1:0]	api_prev_contr_in,
		input	[`C_LENGTH_ADDR_SLOT-1:0]	api_next_contr_in, 
		input	[`C_LENGTH_ADDR_SLOT-1:0]	api_self_slot_in, 
		input	[`C_LENGTH_ADDR_FPGA-1:0]	api_self_fpga_in, 
		// OUTPUT REGISTER PORTS
		output								api_o_clk_out,
		input								api_o_rfd_in,
		output	[`C_LENGTH_ADDR_SLOT-1:0]	api_o_tgt_slot_out,
		output	[`C_LENGTH_ADDR_FPGA-1:0]	api_o_tgt_fpga_out,
		output	[`C_LENGTH_ADDR_REG-1:0]	api_o_tgt_reg_out,
		output	[`C_LENGTH_CMD-1:0]			api_o_tgt_cmd_out,
		output	[`C_LENGTH_ADDR_REG-1:0]	api_o_src_reg_out,
		output	[`C_LENGTH_CMD-1:0]			api_o_src_cmd_out,
		output	[`C_LENGTH_DATA-1:0]		api_o_data_out,
		output								api_o_wr_en_out, 
		// INPUT REGISTER PORTS
		output								api_i_clk_out,
		input	[`C_LENGTH_ADDR_SLOT-1:0]	api_i_src_slot_in,
		input	[`C_LENGTH_ADDR_FPGA-1:0]	api_i_src_fpga_in,
		input	[`C_LENGTH_ADDR_REG-1:0]	api_i_src_reg_in,
		input	[`C_LENGTH_CMD-1:0]			api_i_src_cmd_in,
		input	[`C_LENGTH_ADDR_REG-1:0]	api_i_tgt_reg_in,
		input	[`C_LENGTH_CMD-1:0]			api_i_tgt_cmd_in,
		input	[`C_LENGTH_DATA-1:0]		api_i_data_in,
		input								api_i_empty_in,
		input								api_i_am_empty_in,
		output								api_i_rd_en_out
);

	// Output default values. Comment anyone if you are going to use it.
	assign api_o_tgt_slot_out	= {`C_LENGTH_ADDR_SLOT{1'b0}};
	assign api_o_tgt_fpga_out	= {`C_LENGTH_ADDR_FPGA{1'b0}};
	assign api_o_tgt_reg_out	= {`C_LENGTH_ADDR_REG{1'b0}};
	assign api_o_tgt_cmd_out	= `CMD_WR;
	assign api_o_src_reg_out	= {`C_LENGTH_ADDR_REG{1'b0}};
	assign api_o_src_cmd_out	= `CMD_WR;
	assign api_o_data_out		= {`C_LENGTH_DATA{1'b0}};
	assign api_o_wr_en_out		= 1'b0;
	assign api_i_rd_en_out		= 1'b0;

	// When defining an own clock domain to
	// run the user design with a different
	// clock, the following two lines should
	// probably be altered
	assign api_i_clk_out = api_clk_in;
	assign api_o_clk_out = api_clk_in;

	// A Spartan 3 FPGA has one LED and a Spartan 6 FPGA
	// has two LEDs for debugging purposes.
	// Set these LEDs disabled here. Comment following
	// line and use this signal anywhere you want to!
	assign api_led_out = 0;



endmodule
