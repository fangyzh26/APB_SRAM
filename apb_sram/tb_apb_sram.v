`timescale 1ns/10ps

module tb_apb_sram (); /* this is automatically generated */

    parameter T = 20; // a FPGA clock period

    reg        pclk;	
    reg        prstn;
	reg        psel;
	reg        penable;
	reg        pwrite;
	reg  [9:0] paddr;
	reg [31:0] pwdata;

	wire        pready;
	wire [31:0] prdata;

    // asynchronous reset
	initial begin
		prstn = 'b1;
		#10
		prstn = 'b0;
        #30
		prstn = 'b1;
	end

    // clock
    integer i;
	initial begin
		pclk = 'b1;
        repeat(600) #10 pclk = ~pclk;
	end

    //
    integer j;
    initial begin
        pwrite = 'b0; psel = 'b0; penable = 'b0; pwdata = 'b0;
        //---------------------------------------------- write ---------------------------------------------------
        for(j=0;j<=31;j=j+1) begin
            if(j%2==0) begin
                #20  paddr = j*4;  pwrite = 1; psel = 1; pwdata = {$random} % 2_000_000_000;//(2^32=4294967296)
                #20  penable = 1;
                #20  psel = 0; penable = 0;   
            end
            if(j%2==1) begin
                #20  paddr = j*4;  pwrite = 1; psel = 1; pwdata = {$random} % 2_000_000_000;//(2^32=4294967296)
                #20  penable = 1;
                #20  psel = 0; penable = 0;   
            end
            
        end

        //----------------------------------------------- read ---------------------------------------------------
        for(j=0;j<=31;j=j+1) begin
            if(j%2==0) begin
                #20  paddr = j*4;  pwrite = 0; psel = 1; 
                #20  penable = 1;
                #20  psel = 0; penable = 0;    
            end
            if(j%2==1) begin
                #20  paddr = j*4;  pwrite = 0; psel = 1; 
                #20  penable = 1;
                #20  psel = 0; penable = 0;    
            end
            
        end
    end

    initial begin
		prstn = 'b0;
        #20
		prstn = 'b1;
	end

    //----------------------------------  instance module ------------------------------------------------------
	apb_sram inst_apb_sram
     (
        .pclk    (pclk),//input
        .prstn   (prstn),
        .psel    (psel),
        .penable (penable),
        .pwrite  (pwrite),
        .paddr   (paddr),
        .pwdata  (pwdata),

        .pready  (pready),//output
        .prdata  (prdata)
	);

	//---------------------------------- dump wave ------------------------------------------------------
	initial begin
        $vcdpluson();
    end
        
    initial begin
        $fsdbDumpfile("apb_sram.fsdb");
        $fsdbDumpvars(0);
        $fsdbDumpMDA();// add to see memory
    end

endmodule


