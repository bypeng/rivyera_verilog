`timescale 1ns / 1ps

`include "SciEngines_API_constant.v"

module rivyera_template_main # (
        parameter NUM_LEDS = 2
)(
    //
    // API PORTS
    //
        // GENERAL PORTS
        input                                   api_clk_in,
        input                                   api_rst_in,
        output      [NUM_LEDS-1:0]              api_led_out,
        input       [`C_LENGTH_HW_REV-1:0]      api_hw_rev_in,
        // ADDRESS PORTS
        input                                   api_self_contr_in,
        input       [`C_LENGTH_ADDR_SLOT-1:0]   api_prev_contr_in,
        input       [`C_LENGTH_ADDR_SLOT-1:0]   api_next_contr_in, 
        input       [`C_LENGTH_ADDR_SLOT-1:0]   api_self_slot_in, 
        input       [`C_LENGTH_ADDR_FPGA-1:0]   api_self_fpga_in, 
        // OUTPUT REGISTER PORTS
        output                                  api_o_clk_out,
        input                                   api_o_rfd_in,
        output      [`C_LENGTH_ADDR_SLOT-1:0]   api_o_tgt_slot_out,
        output      [`C_LENGTH_ADDR_FPGA-1:0]   api_o_tgt_fpga_out,
        output      [`C_LENGTH_ADDR_REG-1:0]    api_o_tgt_reg_out,
        output      [`C_LENGTH_CMD-1:0]         api_o_tgt_cmd_out,
        output      [`C_LENGTH_ADDR_REG-1:0]    api_o_src_reg_out,
        output      [`C_LENGTH_CMD-1:0]         api_o_src_cmd_out,
        output reg  [`C_LENGTH_DATA-1:0]        api_o_data_out,
        output                                  api_o_wr_en_out, 
        // INPUT REGISTER PORTS
        output                                  api_i_clk_out,
        input       [`C_LENGTH_ADDR_SLOT-1:0]   api_i_src_slot_in,
        input       [`C_LENGTH_ADDR_FPGA-1:0]   api_i_src_fpga_in,
        input       [`C_LENGTH_ADDR_REG-1:0]    api_i_src_reg_in,
        input       [`C_LENGTH_CMD-1:0]         api_i_src_cmd_in,
        input       [`C_LENGTH_ADDR_REG-1:0]    api_i_tgt_reg_in,
        input       [`C_LENGTH_CMD-1:0]         api_i_tgt_cmd_in,
        input       [`C_LENGTH_DATA-1:0]        api_i_data_in,
        input                                   api_i_empty_in,
        input                                   api_i_am_empty_in,
        output                                  api_i_rd_en_out
);

    localparam S_IDLE = 2'b00;
    localparam S_LOAD = 2'b01;
    localparam S_TASK = 2'b10;

    localparam C_SIZE_ADDR_REG = 1 << `C_LENGTH_ADDR_REG;
    //localparam C_LEN_RDCOUNT = `C_LENGTH_DATA;
    localparam C_LEN_RDCOUNT = 8;
    localparam D_SIZE = `C_LENGTH_ADDR_SLOT + `C_LENGTH_ADDR_FPGA + 2 * `C_LENGTH_ADDR_REG + C_LEN_RDCOUNT;

    reg     [`C_LENGTH_DATA-1:0]        regs [C_SIZE_ADDR_REG-1:0];

    reg     [1:0]                       r_state;
    reg     [1:0]                       r_nextstate;

    reg     [1:0]                       w_state;
    reg     [1:0]                       w_nextstate;
    reg     [C_LEN_RDCOUNT-1:0]         w_counter;
    reg     [C_LEN_RDCOUNT-1:0]         w_nextcounter;

    wire                                clk;
    wire                                rst;
    reg     [3:0]                       rstcounter;

    reg                                 f_we;
    reg     [D_SIZE-1:0]                f_din;
    wire                                f_full;
    wire                                f_re;
    wire    [D_SIZE-1:0]                f_dout;
    wire                                f_empty;

    assign clk = api_clk_in;
    assign rst = |rstcounter;

    always @ (posedge api_clk_in) begin
        if(api_rst_in) begin
            rstcounter <= 4'hf;
        end else begin
            if(rst) rstcounter <= rstcounter + 4'hf; // -1
            else rstcounter <= rstcounter;
        end
    end

    assign api_i_clk_out = api_clk_in;
    assign api_o_clk_out = api_clk_in;
    assign api_led_out = {NUM_LEDS{1'b0}};

    always @ (posedge clk) begin
        r_state <= r_nextstate;
        w_state <= w_nextstate;
        w_counter <= w_nextcounter;
    end

    always @ (*) begin
        if(rst) begin
            r_nextstate = S_IDLE;
        end else begin
            case(r_state)
                S_IDLE: begin
                    if(!api_i_empty_in) begin
                        r_nextstate = S_LOAD;
                    end else begin
                        r_nextstate = S_IDLE;
                    end
                end
                S_LOAD: begin
                    r_nextstate = S_TASK;
                end
                S_TASK: begin
                    if(!f_full) begin
                        r_nextstate = S_IDLE;
                    end else begin
                        r_nextstate = S_TASK;
                    end
                end
                default: begin
                    r_nextstate = S_IDLE;
                end
            endcase
        end
    end

    assign api_i_rd_en_out = (r_state == S_LOAD);

    integer reg_index;
    always @ (posedge clk) begin
        //if(rst) begin
        //    for(reg_index = 0; reg_index < C_SIZE_ADDR_REG; reg_index = reg_index + 1) begin
        //        regs[reg_index] <= { `C_LENGTH_DATA {1'b0} };
        //    end
        //end else begin
            if((r_state == S_IDLE) && (r_nextstate == S_LOAD) && (api_i_tgt_cmd_in == `CMD_WR)) begin
                regs[api_i_tgt_reg_in] <= api_i_data_in;
            end
        //end
    end

    // TODO: 1. Connect the register pool to the core IP.
    //       2. Modify the control registers as necessary.

    always @ (posedge clk) begin
        if(rst) begin
            f_we <= 1'b0;
            f_din <= { D_SIZE {1'b0} };
        end else begin
            if((r_state == S_IDLE) && (r_nextstate == S_LOAD) && (api_i_tgt_cmd_in == `CMD_RD)) begin
                f_we <= 1'b1;
                f_din <= { api_i_src_slot_in, api_i_src_fpga_in, api_i_src_reg_in, api_i_tgt_reg_in, api_i_data_in[C_LEN_RDCOUNT-1:0] };
            end else begin
                f_we <= 1'b0;
                f_din <= f_din;
            end
        end
    end

    fifo # ( .D_SIZE(D_SIZE), .Q_DEPTH(2) ) fifo_read ( .clk(clk), .rst(rst),
             .d_in(f_din), .d_out(f_dout), .wr_en(f_we), .rd_en(f_re), .f_empty(f_empty), .f_full(f_full) );

    always @ (*) begin
        if(rst) begin
            w_nextstate = S_IDLE;
            w_nextcounter = { C_LEN_RDCOUNT { 1'b0 } };
        end else begin
            case(w_state)
                S_IDLE: begin
                    if(!f_empty) begin
                        w_nextstate = S_LOAD;
                        w_nextcounter = { C_LEN_RDCOUNT { 1'b0 } };
                    end else begin
                        w_nextstate = S_IDLE;
                        w_nextcounter = { C_LEN_RDCOUNT { 1'b0 } };
                    end
                end
                S_LOAD: begin
                    w_nextstate = S_TASK;
                    w_nextcounter = f_dout[C_LEN_RDCOUNT-1:0];
                end
                S_TASK: begin
                    if(|w_counter) begin
                        w_nextstate = S_TASK;
                        if(api_o_rfd_in) begin
                            w_nextcounter = w_counter + { C_LEN_RDCOUNT { 1'b1 } }; // - 1
                        end else begin
                            w_nextcounter = w_counter;
                        end
                    end else begin
                        w_nextstate = S_IDLE;
                        w_nextcounter = { C_LEN_RDCOUNT { 1'b0 } };
                    end
                end
                default: begin
                    w_nextstate = S_IDLE;
                    w_nextcounter = { C_LEN_RDCOUNT { 1'b0 } };
                end
            endcase
        end
    end

    assign f_re = (w_state == S_IDLE) && (~f_empty);

    assign api_o_tgt_slot_out = f_dout[(C_LEN_RDCOUNT + 2 * `C_LENGTH_ADDR_REG + `C_LENGTH_ADDR_FPGA) +: `C_LENGTH_ADDR_SLOT];
    assign api_o_tgt_fpga_out = f_dout[(C_LEN_RDCOUNT + 2 * `C_LENGTH_ADDR_REG) +: `C_LENGTH_ADDR_FPGA];
    assign api_o_tgt_reg_out = f_dout[(C_LEN_RDCOUNT + `C_LENGTH_ADDR_REG) +: `C_LENGTH_ADDR_REG];
    assign api_o_tgt_cmd_out = `CMD_WR;
    assign api_o_src_reg_out = f_dout[C_LEN_RDCOUNT +: `C_LENGTH_ADDR_REG];
    assign api_o_src_cmd_out = `CMD_WR;
    assign api_o_wr_en_out = (w_state == S_TASK) && (|w_counter) && (api_o_rfd_in);

    always @ (posedge clk) begin
        if(rst) begin
            api_o_data_out <= { `C_LENGTH_DATA {1'b0} };
        end else begin
            if(w_state == S_LOAD) begin
                api_o_data_out <= regs[api_o_src_reg_out];
            end
        end
    end

endmodule
