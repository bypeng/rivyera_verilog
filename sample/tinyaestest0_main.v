`timescale 1ns / 1ps

`include "SciEngines_API_constant.v"

module tinyaestest0_main # (
        parameter NUM_LEDS = 2
)(
    //
    // API PORTS
    //
        // GENERAL PORTS
        input                               api_clk_in,
        input                               api_rst_in,
        output  [NUM_LEDS-1:0]              api_led_out,
        input   [`C_LENGTH_HW_REV-1:0]      api_hw_rev_in,
        // ADDRESS PORTS
        input                               api_self_contr_in,
        input   [`C_LENGTH_ADDR_SLOT-1:0]   api_prev_contr_in,
        input   [`C_LENGTH_ADDR_SLOT-1:0]   api_next_contr_in, 
        input   [`C_LENGTH_ADDR_SLOT-1:0]   api_self_slot_in, 
        input   [`C_LENGTH_ADDR_FPGA-1:0]   api_self_fpga_in, 
        // OUTPUT REGISTER PORTS
        output                              api_o_clk_out,
        input                               api_o_rfd_in,
        output  [`C_LENGTH_ADDR_SLOT-1:0]   api_o_tgt_slot_out,
        output  [`C_LENGTH_ADDR_FPGA-1:0]   api_o_tgt_fpga_out,
        output  [`C_LENGTH_ADDR_REG-1:0]    api_o_tgt_reg_out,
        output  [`C_LENGTH_CMD-1:0]         api_o_tgt_cmd_out,
        output  [`C_LENGTH_ADDR_REG-1:0]    api_o_src_reg_out,
        output  [`C_LENGTH_CMD-1:0]         api_o_src_cmd_out,
        output  [`C_LENGTH_DATA-1:0]        api_o_data_out,
        output                              api_o_wr_en_out, 
        // INPUT REGISTER PORTS
        output                              api_i_clk_out,
        input   [`C_LENGTH_ADDR_SLOT-1:0]   api_i_src_slot_in,
        input   [`C_LENGTH_ADDR_FPGA-1:0]   api_i_src_fpga_in,
        input   [`C_LENGTH_ADDR_REG-1:0]    api_i_src_reg_in,
        input   [`C_LENGTH_CMD-1:0]         api_i_src_cmd_in,
        input   [`C_LENGTH_ADDR_REG-1:0]    api_i_tgt_reg_in,
        input   [`C_LENGTH_CMD-1:0]         api_i_tgt_cmd_in,
        input   [`C_LENGTH_DATA-1:0]        api_i_data_in,
        input                               api_i_empty_in,
        input                               api_i_am_empty_in,
        output                              api_i_rd_en_out
);

    function is_valid_reg;
        input [`C_LENGTH_ADDR_REG-1:0] reg_select;
        input [`C_LENGTH_ADDR_REG-1:0] upperbound;
        begin
            is_valid_reg = (reg_select <= upperbound && reg_select >= 0);
        end
    endfunction

    reg reset;
    reg [3:0] reset_counter;
    reg [`C_LENGTH_ADDR_REG-1:0] reg_select;
    reg [2:0] i;
    reg [`C_LENGTH_DATA-1:0] data_output;
    reg rd_enable;
    reg wr_enable;
    reg output_data_req;
    reg output_data_ack;

    reg [`C_LENGTH_DATA-1:0] data_inregs [5:0]; // 64-bits registers
    wire [`C_LENGTH_DATA-1:0] data_outregs [1:0];
    wire [127:0] plaintext;
    wire [255:0] key;
    wire [127:0] ciphertext;

    assign plaintext = { api_self_slot_in[2:0], api_self_fpga_in[2:0], data_inregs[1][57:0], data_inregs[0] };
    assign key = { data_inregs[5], data_inregs[4], data_inregs[3], data_inregs[2] };
    assign data_outregs[1] = ciphertext[127:64];
    assign data_outregs[0] = ciphertext[63:0];

    // Output default values. Comment anyone if you are going to use it.
    //assign api_o_tgt_slot_out = api_self_contr_in ? api_self_slot_in : api_next_contr_in;
    assign api_o_tgt_slot_out   = api_i_src_slot_in;
    assign api_o_tgt_fpga_out   = api_i_src_fpga_in;
    assign api_o_tgt_reg_out    = api_i_src_reg_in;
    assign api_o_tgt_cmd_out    = `CMD_WR;
    assign api_o_src_reg_out    = reg_select;
    assign api_o_src_cmd_out    = `CMD_WR;
    assign api_o_data_out       = data_output;
    assign api_o_wr_en_out      = wr_enable;
    assign api_i_rd_en_out      = rd_enable;

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
    assign api_led_out = {NUM_LEDS{1'b0}};

    always @ (posedge api_clk_in) begin
        if(api_rst_in) begin
            reset <= 1'b1;
            reset_counter <= 4'hf;
        end else begin
            if(reset && reset_counter != 4'h0) begin
                reset <= 1'b1;
                reset_counter <= reset_counter - 4'h1;
            end else begin
                reset <= 1'b0;
                reset_counter <= 4'h0;
            end
        end
    end

    always @ (posedge api_clk_in or posedge reset) begin
        if(reset) begin
            rd_enable <= 1'b0;
            output_data_req <= 1'b0;
            reg_select <= {`C_LENGTH_ADDR_REG{1'b0}};
            for( i = 0; i < 6; i = i + 1 ) data_inregs[i] <= {`C_LENGTH_DATA{1'b0}};
        end else begin
            rd_enable <= 1'b0;
            if(output_data_ack == 1'b1) begin
                output_data_req <= 1'b0;
            end else begin
                if(api_i_empty_in == 1'b0 && rd_enable == 1'b0) begin
                    rd_enable <= 1'b1;
                    if(api_i_tgt_cmd_in == `CMD_RD) begin
                        reg_select <= api_i_tgt_reg_in;
                        output_data_req <= 1'b1;
                    end else begin
                        if(is_valid_reg(api_i_tgt_reg_in, 5)) begin
                            data_inregs[api_i_tgt_reg_in] <= api_i_data_in;
                        end
                    end
                end
            end
        end
    end

    always @ (posedge api_clk_in or posedge reset) begin
        if(reset) begin
            output_data_ack <= 1'b0;
            wr_enable <= 1'b0;
            data_output <= {`C_LENGTH_DATA{1'b0}};
        end else begin
            output_data_ack <= 1'b0;
            wr_enable <= 1'b0;
            if(output_data_req == 1'b1 && api_o_rfd_in == 1'b1 && output_data_ack == 1'b0) begin
                output_data_ack <= 1'b1;
                wr_enable <= 1'b1;
                if(is_valid_reg(reg_select, 5)) begin
                    data_output <= data_inregs[reg_select];
                end else begin
                    data_output <= data_outregs[reg_select[0]];
                end
            end
        end
    end

    //assign ciphertext = 128'hffffffff_00000000_55555555_aaaaaaaa;
    aes_256 aes_256_0 (
        .clk(api_clk_in),
        .state(plaintext),
        .key(key),
        .out(ciphertext)
    );

endmodule

