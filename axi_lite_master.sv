`include "axi_lite_pkg"

module axi_lite_master #(
    ADDR_WIDTH = 32,
    DATA_WIDTH  = 32
) (
    input  logic                    start_read,
    input  logic                    start_write,
    input  logic                    ACLK,
    input  logic                    ARESETn,

    axi_lite_if.master              M_AXI_LITE,

    // inputs to master that gets transferred by the AXI protocol
    input logic [ADDR_WIDTH-1 : 0] waddr,
    input logic [DATA_WIDTH-1 : 0] wdata,
    input logic [DATA_WIDTH/8-1:0] wstrb,
    input logic [ADDR_WIDTH-1 : 0] raddr
);

import axi_lite_pkg::*;

state_e state, next;
logic start_read_d, start_write_d;

// AW
assign M_AXI_LITE.AWVALID = (state==WADDR) ? 1 : 0;
assign M_AXI_LITE.AWADDR  = (state==WADDR) ? waddr : 'x;
assign M_AXI_LITE.AWPROT  = '0;

// W
assign M_AXI_LITE.WVALID = (state==WDATA) ? 1 : 0;
assign M_AXI_LITE.WDATA = (state==WDATA) ? wdata : 'x;
assign M_AXI_LITE.WSTRB = (state==WDATA) ? wstrb : 'x;

// B
assign M_AXI_LITE.BREADY = (state==BRESP) ? 1 : 0;

// AR
assign M_AXI_LITE.ARVALID = (state==RADDR) ? 1 : 0;
assign M_AXI_LITE.ARPROT = '0;
assign M_AXI_LITE.ARADDR = (state==RADDR) ? raddr : 'x;

// R
assign M_AXI_LITE.RREADY = (state==RDATA) ? 1 : 0;

// start transaction only at posedge clock 
always_ff @(posedge ACLK, negedge ARESETn) begin
    if (~ARESETn) begin
        start_read_d  <= 0;
        start_write_d <= 0;
    end
    else begin
        start_read_d  <= start_read;
        start_write_d <= start_write;
    end
    
end


// next state logic
always_comb begin
    next = state;
    case (state)
        IDLE: if (start_read_d)                               next = RADDR;
              else if (start_write_d)                         next = WADDR;
        RADDR: if(M_AXI_LITE.ARVALID & M_AXI_LITE.ARREADY)    next = RDATA;
        RDATA: if(M_AXI_LITE.RVALID & M_AXI_LITE.RREADY)      next = IDLE;
        WADDR: if(M_AXI_LITE.AWVALID & M_AXI_LITE.AWREADY)    next = WDATA;
        WDATA: if(M_AXI_LITE.WVALID & M_AXI_LITE.WREADY)      next = BRESP;
        BRESP: if(M_AXI_LITE.BVALID & M_AXI_LITE.BREADY)      next = IDLE;
        default:                                              next = state;
    endcase
end

// state register
always_ff @(posedge ACLK, negedge ARESETn) 
    if(~ARESETn)    state <= IDLE;
    else            state <= next;
endmodule
