`include "axi_lite_pkg"

module axi_lite_slave(
    input logic         ACLK,
    input logic         ARESETn,

    axi_lite_if.slave   S_AXI_LITE,

    input  logic [31:0] rdata,
    output logic [31:0] addr,
    output logic [31:0] wdata
);

import axi_lite_pkg::*;

state_e state, next;

// AW
assign S_AXI_LITE.AWREADY = (state == WADDR) ? 1 : 0;
// W
assign wdata = (state == WDATA) ? S_AXI_LITE.WDATA : 'x; 
assign S_AXI_LITE.WREADY = (state == WDATA) ? 1 : 0;
// B
assign S_AXI_LITE.BVALID = (state == BRESP) ? 1 : 0;
assign S_AXI_LITE.BRESP = 'b0; // OKAY
// AR
assign S_AXI_LITE.ARREADY = (state == RADDR) ? 1: 0;
// R
assign S_AXI_LITE.RDATA = (state == RDATA) ? rdata : 'x;
assign S_AXI_LITE.RRESP = 'b0; // OKAY
assign S_AXI_LITE.RVALID = (state == RDATA) ? 1 : 0;

always_ff @(posedge ACLK, negedge ARESETn) begin
    if (~ARESETn) addr <= '0;
    else case (state)
        WADDR :  addr <= S_AXI_LITE.AWADDR;
        RADDR :  addr <= S_AXI_LITE.ARADDR;
        default: addr <= 'x;
    endcase
end


always_comb begin
    next = state;
    case (state)
        IDLE: if (S_AXI_LITE.ARVALID)                         next = RADDR;
              else if (S_AXI_LITE.AWVALID)                    next = WADDR;
        RADDR: if(S_AXI_LITE.ARVALID & S_AXI_LITE.ARREADY)    next = RDATA;
        RDATA: if(S_AXI_LITE.RVALID & S_AXI_LITE.RREADY)      next = IDLE;
        WADDR: if(S_AXI_LITE.AWVALID & S_AXI_LITE.AWREADY)    next = WDATA;
        WDATA: if(S_AXI_LITE.WVALID & S_AXI_LITE.WREADY)      next = BRESP;
        BRESP: if(S_AXI_LITE.BVALID & S_AXI_LITE.BREADY)      next = IDLE;
        default:                                              next = state;
    endcase
end


always_ff @(posedge ACLK, negedge ARESETn) 
    if (~ARESETn) state <= IDLE;
    else          state <= next;
endmodule
