module apb_sram( //a control module between bridge and sram!!!
    input           pclk,//input from bridge
    input           prstn,
    input           psel,
    input           penable,
    input           pwrite,
    input [11:0]    paddr,
    input [31:0]    pwdata,
    input           respon, //input from sram

    output          pready, //output to bridge
    output [31:0]   prdata  //output to bridge
    );

    parameter IDLE      = 3'b001; // state define
    parameter SETUP     = 3'b010;
    parameter ACCESS    = 3'b100;

    // reg          ready;
    // reg [1:0]    ready_delay;
    reg [2:0]    now_state, next_state;

    //-------------------------------- FSM-1: state transfer ---------------------------------------------------
    always @(posedge pclk, negedge prstn) begin 
        if (!prstn) begin
            now_state <= IDLE;
        end
        else begin
            now_state <= next_state;
        end
    end

    //-------------------------------- FSM-2: state transfer condition------------------------------------------
    always @(*) begin
        if (!prstn) begin
            next_state <= IDLE;
        end
        else begin
            case (now_state)
                IDLE:begin
                    if(psel && !penable) begin
                        next_state <= SETUP;
                    end
                    else begin
                        next_state <= IDLE;
                    end
                end
                SETUP:begin
                    next_state <= ACCESS;
                end
                ACCESS:begin
                    if (!psel && !penable) begin
                        next_state <= IDLE;
                    end
                    else if (psel && !penable) begin
                        next_state <= SETUP;
                    end
                    else begin
                        next_state <= now_state;
                    end
                end
                default:
                    next_state <= IDLE;
            endcase
        end
    end

    //-------------------------------- FSM-3: logic judgment ------------------------------------------
    wire         mem_en;
    wire         mem_we;
    wire [9:0]   apb_addr;
    wire [31:0]  apb_wdata;

    assign       mem_en    = penable;
    assign       mem_we    = penable ? pwrite : mem_we;
    assign       apb_addr  = (next_state==SETUP) ? paddr[11:2] : apb_addr ;
    assign       apb_wdata = (next_state==SETUP) ? pwdata : apb_wdata ;
    assign       pready    = penable;

    //------------------------------  slave connection ------------------------------------------------
    sram inst_sram
    (
        .clk   (pclk),//input
        .rst_n (prstn),
        .en    (mem_en),
        .we    (mem_we),
        .addr  (apb_addr),
        .din   (apb_wdata),

        // .ready (respon),//output
        .dout  (prdata)
    );

endmodule