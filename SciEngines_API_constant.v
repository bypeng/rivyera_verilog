`ifndef SCIENGINES_API_CONST
`define SCIENGINES_API_CONST
	`define C_LENGTH_ADDR_SLOT 10
		`define ADDR_SLOT_ALL 10'h3ff
	`define C_LENGTH_ADDR_FPGA 5
		`define ADDR_FPGA_ALL 5'h1f
		`define ADDR_FPGA_HOST 5'h1e
	`define C_LENGTH_ADDR_REG 6
		`define ADDR_REG_EOT 6'h3f
	`define C_LENGTH_CMD 1
		`define CMD_RD 1'b0
		`define CMD_WR 1'b1
	`define C_LENGTH_DATA 64
	`define C_LENGTH_HW_REV 8
`endif // SCIENGINES_API_CONST

