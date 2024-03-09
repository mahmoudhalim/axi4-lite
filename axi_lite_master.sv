module axi_lite_master #(
    ADDR_WIDTH = 32,
    DATA_WIDTH  = 32
) (
    input  logic                    start_read,
    input  logic                    start_write,
    input  logic                    ACLK,
    input  logic                    ARESETn,

    // AW
    output logic                    AWVALID,
    output logic [ADDR_WIDTH-1 : 0] AWADDR,
    output logic [2 : 0]            AWPROT,
    input  logic                    AWREADY,
    
    // W
    output logic [DATA_WIDTH-1 : 0] WDATA,
    output logic [DATA_WIDTH/8-1:0] WSTRB,
    output logic                    WVAlID,
    input  logic                    WREADY,

    // B
    input  logic [1 : 0]            BRESP,
    input  logic                    BVALID,
    output logic                    BREADY,

    // AR
    output logic [ADDR_WIDTH-1 : 0] ARADDR,
    output logic [2 : 0]            ARPROT,
    output logic                    ARVALID,
    input  logic                    ARREADY,

    // R
    input  logic [DATA_WIDTH-1 : 0] RDATA,
    input  logic [1 : 0]            RRESP,
    input  logic                    RVAlID,
    output logic                    RREADY,

    // inputs to master that gets transferred by the AXI protocol
    input logic [ADDR_WIDTH-1 : 0] waddr,
    input logic [DATA_WIDTH-1 : 0] wdata,
    input logic [DATA_WIDTH/8-1:0] wstrb,
    input logic [ADDR_WIDTH-1 : 0] raddr,

    
);

typedef enum logic {IDLE, RADDR, RDATA, WADDR, WDATA, BRESP} state_e;
state_e state, next;
logic start_read_d, start_write_d;

// AW
assign AWVALID = (state==AWADDR) ? 1 : 0;
assign AWADDR  = (state==AWADDR) ? waddr : 'x;
assign AWPROT  = '0;

// W
assign WVAlID = (state==WDATA) ? 1 : 0;
assign WDATA = (state==WDATA) ? wdata : 'x;
assign WSTRB = (state==WDATA) ? wstrb : 'x;

// B
assign BREADY = (state==BRESP) ? 1 : 0;

// AR
assign ARVALID = (state==RADDR) ? 1 : 0;
assign ARPROT = '0;
assign ARADDR = (state==RADDR) ? raddr : 'x;

// R
assign RREADY = (state==RDATA) ? 1 : 0;

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
        IDLE: if (start_read_d)           next = RADDR;
              else if (start_write_d)     next = WADDR;
        RADDR: if(ARVALID & ARREADY)    next = RDATA;
        RDATA: if(RVALID & RREADY)      next = IDLE;
        WADDR: if(AWVALID & AWREADY)    next = WDATA;
        WDATA: if(WVAlID & WREADY)      next = WRESP;
        BRESP: if(BVALID & BREADY)      next = IDLE;
        default:                        next = state;
    endcase

end

// state register
always_ff @(posedge ACLK, negedge ARESETn) 
    if(~ARESETn)    state <= IDLE;
    else            state <= next;
endmodule
