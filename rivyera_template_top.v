`timescale 1ns / 1ps

`include "SciEngines_API.v"
`include "SciEngines_API_constant.v"

module rivyera_template_top (
    input                               CPI_CLK, 
    output  [1:0]                       CPO_CLK, 
    input                               CNI_CLK, 
    output  [1:0]                       CNO_CLK, 
    input   [16:0]                      CPI, 
    output  [16:0]                      CPO, 
    input   [16:0]                      CNI, 
    output  [16:0]                      CNO, 
    output  [`C_NUM_LEDS-1:0]           LED
);

    wire                                api_clk;
    wire                                api_rst;
    wire    [`C_NUM_LEDS-1:0]           api_led;
    wire    [`C_LENGTH_HW_REV-1:0]      api_hw_rev;

    wire                                api_self_contr;
    wire    [`C_LENGTH_ADDR_SLOT-1:0]   api_prev_contr;
    wire    [`C_LENGTH_ADDR_SLOT-1:0]   api_next_contr; 
    wire    [`C_LENGTH_ADDR_SLOT-1:0]   api_self_slot;
    wire    [`C_LENGTH_ADDR_FPGA-1:0]   api_self_fpga;

    wire                                api_o_clk;
    wire                                api_o_rfd;
    wire    [`C_LENGTH_ADDR_SLOT-1:0]   api_o_tgt_slot;
    wire    [`C_LENGTH_ADDR_FPGA-1:0]   api_o_tgt_fpga;
    wire    [`C_LENGTH_ADDR_REG-1:0]    api_o_tgt_reg;
    wire    [`C_LENGTH_CMD-1:0]         api_o_tgt_cmd;
    wire    [`C_LENGTH_ADDR_REG-1:0]    api_o_src_reg;
    wire    [`C_LENGTH_CMD-1:0]         api_o_src_cmd;
    wire    [`C_LENGTH_DATA-1:0]        api_o_data;
    wire                                api_o_wr_en;

    wire                                api_i_clk;
    wire    [`C_LENGTH_ADDR_SLOT-1:0]   api_i_src_slot;
    wire    [`C_LENGTH_ADDR_FPGA-1:0]   api_i_src_fpga;
    wire    [`C_LENGTH_ADDR_REG-1:0]    api_i_src_reg;
    wire    [`C_LENGTH_CMD-1:0]         api_i_src_cmd;
    wire    [`C_LENGTH_ADDR_REG-1:0]    api_i_tgt_reg;
    wire    [`C_LENGTH_CMD-1:0]         api_i_tgt_cmd;
    wire    [`C_LENGTH_DATA-1:0]        api_i_data;
    wire                                api_i_empty;
    wire                                api_i_am_empty;
    wire                                api_i_rd_en;
    
    rivyera_template_main main0 (
        .api_clk_in(api_clk),
        .api_rst_in(api_rst),
        .api_led_out(api_led),
        .api_hw_rev_in(api_hw_rev),
        .api_self_contr_in(api_self_contr),
        .api_prev_contr_in(api_prev_contr),
        .api_next_contr_in(api_next_contr),
        .api_self_slot_in(api_self_slot),
        .api_self_fpga_in(api_self_fpga),
        .api_o_clk_out(api_o_clk),
        .api_o_rfd_in(api_o_rfd),
        .api_o_tgt_slot_out(api_o_tgt_slot),
        .api_o_tgt_fpga_out(api_o_tgt_fpga),
        .api_o_tgt_reg_out(api_o_tgt_reg),
        .api_o_tgt_cmd_out(api_o_tgt_cmd),
        .api_o_src_reg_out(api_o_src_reg),
        .api_o_src_cmd_out(api_o_src_cmd),
        .api_o_data_out(api_o_data),
        .api_o_wr_en_out(api_o_wr_en),
        .api_i_clk_out(api_i_clk),
        .api_i_src_slot_in(api_i_src_slot),
        .api_i_src_fpga_in(api_i_src_fpga),
        .api_i_src_reg_in(api_i_src_reg),
        .api_i_src_cmd_in(api_i_src_cmd),
        .api_i_tgt_reg_in(api_i_tgt_reg),
        .api_i_tgt_cmd_in(api_i_tgt_cmd),
        .api_i_data_in(api_i_data),
        .api_i_empty_in(api_i_empty),
        .api_i_am_empty_in(api_i_am_empty),
        .api_i_rd_en_out(api_i_rd_en)
    );
    
    SciEngines_API se_api_core0 (
        .CPI_CLK(CPI_CLK),
        .CPO_CLK(CPO_CLK),
        .CNI_CLK(CNI_CLK),
        .CNO_CLK(CNO_CLK),
        .CPI(CPI),
        .CPO(CPO),
        .CNI(CNI),
        .CNO(CNO),
        .LED(LED),
        .api_clk_out(api_clk),
        .api_rst_out(api_rst),
        .api_led_in(api_led),
        .api_hw_rev_out(api_hw_rev),
        .api_self_contr_out(api_self_contr),
        .api_prev_contr_out(api_prev_contr),
        .api_next_contr_out(api_next_contr),
        .api_self_slot_out(api_self_slot),
        .api_self_fpga_out(api_self_fpga),
        .api_o_clk_in(api_o_clk),
        .api_o_rfd_out(api_o_rfd),
        .api_o_tgt_slot_in(api_o_tgt_slot),
        .api_o_tgt_fpga_in(api_o_tgt_fpga),
        .api_o_tgt_reg_in(api_o_tgt_reg),
        .api_o_tgt_cmd_in(api_o_tgt_cmd),
        .api_o_src_reg_in(api_o_src_reg),
        .api_o_src_cmd_in(api_o_src_cmd),
        .api_o_data_in(api_o_data),
        .api_o_wr_en_in(api_o_wr_en),
        .api_i_clk_in(api_i_clk),
        .api_i_src_slot_out(api_i_src_slot),
        .api_i_src_fpga_out(api_i_src_fpga),
        .api_i_src_reg_out(api_i_src_reg),
        .api_i_src_cmd_out(api_i_src_cmd),
        .api_i_tgt_reg_out(api_i_tgt_reg),
        .api_i_tgt_cmd_out(api_i_tgt_cmd),
        .api_i_data_out(api_i_data),
        .api_i_empty_out(api_i_empty),
        .api_i_am_empty_out(api_i_am_empty),
        .api_i_rd_en_in(api_i_rd_en)
    );

endmodule

