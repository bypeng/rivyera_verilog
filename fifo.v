module fifo ( clk, rst, d_in, d_out, wr_en, rd_en, f_empty, f_full, count );

    parameter D_SIZE = 32;
    parameter Q_DEPTH = 4;

    localparam Q_SIZE = 1 << Q_DEPTH;

    input                       clk;
    input                       rst;
    input       [D_SIZE-1:0]    d_in;
    output reg  [D_SIZE-1:0]    d_out;
    input                       wr_en;
    input                       rd_en;
    output                      f_empty;
    output                      f_full;
    output reg  [Q_DEPTH:0]     count;

    wire        [D_SIZE-1:0]    dout_bram;

    generate
        if(Q_DEPTH > 0) begin
            reg         [Q_DEPTH-1:0]   wr_ptr;
            reg         [Q_DEPTH-1:0]   rd_ptr; 

            always @ (posedge clk) begin
                if (rst) begin
                    wr_ptr <= { Q_DEPTH{1'b0} };
                    rd_ptr <= { Q_DEPTH{1'b0} };
                end else begin
                    if( !f_full && wr_en )
                        wr_ptr <= wr_ptr + { {(Q_DEPTH-1){1'b0}}, 1'b1 };
                    else
                        wr_ptr <= wr_ptr;
    
                    if( !f_empty && rd_en )
                        rd_ptr <= rd_ptr + { {(Q_DEPTH-1){1'b0}}, 1'b1 };
                    else
                        rd_ptr <= rd_ptr;
                end
            end

            always @ (posedge clk) begin
                if(rst) begin
                    d_out <= { D_SIZE {1'b0} };
                end else begin
                    if( !f_empty && rd_en ) d_out <= dout_bram;
                end
            end    

            bram # ( .D_SIZE(D_SIZE), .Q_DEPTH(Q_DEPTH) )
                 bram0 ( .clk(clk), .wr_en(!f_full && wr_en), .wr_addr(wr_ptr), .rd_addr(rd_ptr), .wr_din(d_in), .rd_dout(dout_bram) );
        end else begin
            reg [D_SIZE-1:0] ram;

            always @ (posedge clk) begin
                if(!f_full && wr_en) begin
                    ram <= d_in;
                end
            end

            always @ (posedge clk) begin
                if(rst) begin
                    d_out <= { D_SIZE {1'b0} };
                end else begin
                    if( !f_empty && rd_en ) d_out <= ram;
                end
            end
        end
    endgenerate
    
    assign f_empty = ~(|count);
    assign f_full = (count[Q_DEPTH] == 1'b1);
    
    always @ (posedge clk) begin
        if (rst) begin
            count <= { (Q_DEPTH+1){1'b0} };
        end else begin
            if ( !f_full & wr_en & !rd_en ) begin
                count <= count + { {Q_DEPTH{1'b0}}, 1'b1 };
            end else if ( !f_empty & rd_en & !wr_en ) begin
                count <= count + { {Q_DEPTH{1'b1}}, 1'b1 }; // - 1
            end else begin
                count <= count;
            end
        end
    end
    
endmodule

