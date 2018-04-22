module i2c_tester(

inout SDA, 
inout SCL, 
input xtal_50M, 					// 50MHZ Crystal input
input [9:0] ADC_BUS_IN, 		// D0-D9 for 10b ADC
output ADC_STROBE_OUT, 			// PLL, XTAL derived strobe
output ADC_STROBE_PLL_LOCKED,	// PLL locked signal
output [31:0] BUFFERED_DATA_OUT,	// data buffer for GPIF2 interface
output FRAME_STROBE_OUT,				// strobe to the GPIF2 interface
output ADC_SHDN_OUT,
/// AUXILLIARY TEST POINTS, REMOVE AFTER DEVELOPMENT
output reg frame_strobe_driver,
output reg msb_ready
);

assign ADC_SHDN_OUT = 1;// never shut down.

// data to be pushed to the GPIF2 interface will be 
// formatted to contain two samples with a clock tick occupying extra 6
// bits from each sample to get timing info
reg [31:0] frame_buffer;
assign BUFFERED_DATA_OUT = frame_buffer; // ya i could reg this, but i didnt...

// data frame strobe, before delays
//reg frame_strobe_driver;

// uncomment to delay the frame strobe by 2 propigation delays to avoid meta
//wire frame_delay1;
//wire frame_delay2;
//assign frame_delay1 = !frame_strobe_driver;
//assign frame_delay2 = !frame_delay1;
assign FRAME_STROBE_OUT = frame_strobe_driver;

// flag indicating that the buffer is half-full, so the bits need to go to MSB
//reg msb_ready;
wire load_buffer_MSB;

// avoid startup BS, make it depend on PLL lock
assign load_buffer_MSB = (msb_ready & ADC_STROBE_PLL_LOCKED);

// tic counter, it may be nice to get a counter IC instead, to count at higher rate
reg [5:0] tic_counter;

/// clock fan out
assign ADC_STROBE_OUT = c0_sig;
//assign ADC_STROBE_OUT = c0_sig;
//assign ADC_STROBE_OUT = c0_sig;
//assign ADC_STROBE_OUT = c0_sig;
//assign ADC_STROBE_OUT = c0_sig;
// a latched clock
//assign ADC_STROBE_OUT = latch_signal ? c0_sig : 1'bz;


// PLL reset signal
reg areset_sig;
// PLL output
wire c0_sig;
/// ADC Strobe instanciation.
/// Designed to operate at 125MHz.
/// This is a solid block, you will need
/// to regenerate the PLL to change the 
/// frequency.
ADC_Strobe	ADC_Strobe_inst (
	.areset ( areset_sig ),
	.inclk0 ( xtal_50M ),
	.c0 ( c0_sig ),
	.locked ( ADC_STROBE_PLL_LOCKED )
	);
// end of strobe PLL instance

/// Data aquisition loop, negedge to avoid meta from ADC
always @(negedge c0_sig) begin
	
	// increase tic counter, not sure why simple +=1 didnt work...
	tic_counter = tic_counter > 6'b111110 ? 6'b0 : (tic_counter+6'b000001);
	
	// flip the MSB ready flag
	msb_ready = !msb_ready;
	
	// load the buffer
	if(msb_ready)
		frame_buffer[31:16] = {tic_counter,ADC_BUS_IN};
	else
		frame_buffer[15:0] = {tic_counter,ADC_BUS_IN};
		
	// pop the clock at MSB rate if we're locked
	frame_strobe_driver = load_buffer_MSB;
	
end
// end of basic data loop

// end of module
endmodule
