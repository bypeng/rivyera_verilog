`timescale 1ns / 1ps

// \brief This package contains all the different setups of the 
// SciEngines RIVYERA API. 
// These cores contain all the ports needed to use the SciEngines RIVYERA API. 
// They completely take care of all the internals, so you may easily 
// instantiate this component and use it as described in the Machine-API 
// documentation. 
// Instantiate only one component in your Top Level code. 
`include "SciEngines_API_constant.v"

module SciEngines_API #(
	parameter	NUM_LEDS = `C_NUM_LEDS,
				LENGTH_ADDR_SLOT = `C_LENGTH_ADDR_SLOT,
				LENGTH_ADDR_FPGA = `C_LENGTH_ADDR_FPGA,
				LENGTH_ADDR_REG = `C_LENGTH_ADDR_REG,
				LENGTH_CMD = `C_LENGTH_CMD,
				LENGTH_DATA = `C_LENGTH_DATA,
				LENGTH_HW_REV = `C_LENGTH_HW_REV	
) (
	//
	// EXTERNAL PORTS
	//
		input							CPI_CLK, 
		output	[1:0]					CPO_CLK, 
		input							CNI_CLK, 
		output	[1:0]					CNO_CLK, 
		input	[16:0]					CPI, 
		output	[16:0]					CPO, 
		input	[16:0]					CNI, 
		output	[16:0]					CNO, 
		output	[NUM_LEDS-1:0]			LED,
	//
	// API PORTS
	//
		// GENERAL PORTS
		output							api_clk_out,
		output							api_rst_out,
		input	[NUM_LEDS-1:0]			api_led_in,
		output	[LENGTH_HW_REV-1:0]		api_hw_rev_out,
		// ADDRESS PORTS
		output							api_self_contr_out, 
		output	[LENGTH_ADDR_SLOT-1:0]	api_prev_contr_out, 
		output	[LENGTH_ADDR_SLOT-1:0]	api_next_contr_out, 
		output	[LENGTH_ADDR_SLOT-1:0]	api_self_slot_out, 
		output	[LENGTH_ADDR_FPGA-1:0]	api_self_fpga_out, 
		// OUTPUT REGISTER PORTS
		input							api_o_clk_in,
		output							api_o_rfd_out,
		input	[LENGTH_ADDR_SLOT-1:0]	api_o_tgt_slot_in,
		input	[LENGTH_ADDR_FPGA-1:0]	api_o_tgt_fpga_in,
		input	[LENGTH_ADDR_REG-1:0]	api_o_tgt_reg_in,
		input	[LENGTH_CMD-1:0]		api_o_tgt_cmd_in,
		input	[LENGTH_ADDR_REG-1:0]	api_o_src_reg_in,
		input	[LENGTH_CMD-1:0]		api_o_src_cmd_in,
		input	[LENGTH_DATA-1:0]		api_o_data_in,
		input							api_o_wr_en_in, 
		// INPUT REGISTER PORTS
		input							api_i_clk_in,
		output	[LENGTH_ADDR_SLOT-1:0]	api_i_src_slot_out,
		output	[LENGTH_ADDR_FPGA-1:0]	api_i_src_fpga_out,
		output	[LENGTH_ADDR_REG-1:0]	api_i_src_reg_out,
		output	[LENGTH_CMD-1:0]		api_i_src_cmd_out,
		output	[LENGTH_ADDR_REG-1:0]	api_i_tgt_reg_out,
		output	[LENGTH_CMD-1:0]		api_i_tgt_cmd_out,
		output	[LENGTH_DATA-1:0]		api_i_data_out,
		output							api_i_empty_out,
		output							api_i_am_empty_out,
		input							api_i_rd_en_in
);
  
endmodule

