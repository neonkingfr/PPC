
module blockRam_memory_II #(parameter WIDTH = 32)(
			clk,
			ena,
			wea,
			addra,
			dina,
			douta
		);
		
		input 						clk;
		input						ena;
		input	[3:0]				wea;
		input	[13:0]				addra;
		input	[WIDTH-1:0]			dina;
		output	[WIDTH-1:0]			douta;
		
		reg [WIDTH-1:0]		dmem[16383:0];
		initial begin 	
        $readmemh("G:/Vivado_data/PPC_Cache/PPC_Cache.srcs/sources_1/new/blockMemory.mem",dmem);
        $display("0x00: %h", dmem[10'b0000000000]);
        //$display("0x01: %h", dmem[10'b0000000001]);
        //$display("0x55: %h", dmem[10'b0000000010]);
        //$display("0x56: %h", dmem[10'b0000000011]);
        end
		always @(posedge clk) begin
			if(ena) begin
				case(wea)
					4'b1111: dmem[addra] <= dina;
					default: ;
				endcase
			end
		end //end always
		
		assign	douta = dmem[addra];
		
endmodule				
		