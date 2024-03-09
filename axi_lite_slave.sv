module axi_lite_slave(
    input logic ACLK,
    input logic ARESETn,

    axi_lite_if.slave S_AXI_LITE
);
typedef enum logic {IDLE, RADDR, RDATA, WADDR, WDATA, BRESP} state_e;
state_e state, next;
    

always_ff @(posedge ACLK, negedge ARESETn) 
    if (~ARESETn) state <= IDLE;
    else          state <= next;
endmodule
