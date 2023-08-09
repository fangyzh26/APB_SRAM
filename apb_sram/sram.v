module sram(
    input               clk,
    input               rst_n,
    input               en,
    input               we,//write enable: 1write  0read
    input [9:0]         addr,
    input [31:0]        din,

    // output reg          ready,
    output reg [31:0]   dout
    );

    integer i;
    // reg delay_factor;

    reg [31:0] mem [31:0]; //dinfine a ram, depth=32, data width=32bit

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            // delay_factor <= 'd0;
            for (i=0; i<=31; i=i+1) begin
                mem[i] <= 'b0;
            end
        end
        else if(en) begin
            if(we)
                mem[addr]   <= din; // write data
            else 
                dout        <= mem[addr]; //read data
            // #(40*delay_factor) ready = 1;
            // delay_factor = delay_factor + 1;
            // //just to simulate a ready signal
            // //actually, using sram ip, do not use this pattern, which can't be synthesized
            // #21 ready = 0;
        end
    end
    
endmodule