module axi_lite_master #(
    ADDR_WIDTH = 32,
    DATA_WIDTH  = 32
) (
    input  logic                    ACLK,
    input  logic                    ARESETn,

    // AW
    output logic                    AWVALID,
    output logic [ADDR_WIDTH-1 : 0] AWADDR,
    output logic [2 : 0]            AWPROT,
    input  logic                    AWREADY,
    
    // W
    output logic [DATA_WIDTH-1 : 0] WDATA,
    output logic [DATA_WIDTH/8 : 0] WSTRB,
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
    output logic [DATA_WIDTH-1 : 0] RDATA,
    output logic [1 : 0]            RRESP,
    output logic                    RVAlID,
    input  logic                    RREADY,
);
    
endmodule