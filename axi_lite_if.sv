interface axi_lite_if;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    // AW
    logic                    AWVALID;
    logic [ADDR_WIDTH-1 : 0] AWADDR;
    logic [2 : 0]            AWPROT;
    logic                    AWREADY;  
    
    // W 
    logic [DATA_WIDTH-1 : 0] WDATA;
    logic [DATA_WIDTH/8-1:0] WSTRB;
    logic                    WVALID;
    logic                    WREADY; 
    
    // B resp
    logic [1 : 0]            BRESP;
    logic                    BVALID;
    logic                    BREADY; 
    
    // AR
    logic [ADDR_WIDTH-1 : 0] ARADDR;
    logic [2 : 0]            ARPROT;
    logic                    ARVALID;
    logic                    ARREADY; 
    
    // R
    logic [DATA_WIDTH-1 : 0] RDATA;
    logic [1 : 0]            RRESP;
    logic                    RVALID;
    logic                    RREADY;

    modport master (
    output AWVALID, AWADDR, AWPROT,
    input AWREADY,

    output WDATA, WSTRB, WVALID,
    input WREADY,

    output BREADY,
    input BRESP, BVALID,

    output ARADDR, ARPROT, ARVALID,
    input ARREADY,

    output RREADY,
    input RDATA, RRESP, RVALID
    );

    modport slave (
    input AWVALID, AWADDR, AWPROT,
    output AWREADY,

    input WDATA, WSTRB, WVALID,
    output WREAD,

    input BREADY,
    output BRESP, BVALID,

    input ARADDR, ARPROT, ARVALID,
    output ARREADY,

    input RREADY,
    output RDATA, RRESP, RVALID
    );

endinterface 
