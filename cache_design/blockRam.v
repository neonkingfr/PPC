module blockRam_data #(parameter WIDTH = 128)(
			clk,
			ena,
			wea,
			addra,
			dina,
			douta
		);
		
		input 						clk;
		input						ena;
		input	[15:0]				wea;
		input	[9:0]				addra;
		input	[WIDTH-1:0]			dina;
		output	[WIDTH-1:0]			douta;
		
		reg [WIDTH-1:0] dmem[1023:0];
		initial begin 
		$readmemh ("G:/Vivado_data/PPC_Cache/PPC_Cache.srcs/sources_1/new/cache_data.mem",dmem);
		$display("0x00: %h", dmem[10'b0000000000]);
        $display("0x01: %h", dmem[10'b0000000001]);
        $display("0x55: %h", dmem[10'b0000000010]);
        $display("0x56: %h", dmem[10'b0000000011]);
		end
		

		always @(posedge clk) begin
			if(ena) begin
				case(wea)
					//word select
					16'h000f: dmem[addra][31:0]    <= dina[31:0];
					16'h00f0: dmem[addra][63:32]   <= dina[63:32];
					16'h0f00: dmem[addra][95:64]   <= dina[95:64];
					16'hf000: dmem[addra][127:96]  <= dina[127:96];
					//half word select
					16'h0003: dmem[addra][15:0]     <= dina[15:0];
					16'h000c: dmem[addra][31:16]    <= dina[31:16];
					16'h0030: dmem[addra][47:32]    <= dina[47:32];
					16'h00c0: dmem[addra][63:48]    <= dina[63:48];
					16'h0300: dmem[addra][79:64]    <= dina[79:64];
					16'h0c00: dmem[addra][95:80]    <= dina[95:80];
					16'h3000: dmem[addra][111:96]   <= dina[111:96];
					16'hc000: dmem[addra][127:112]  <= dina[127:112];
					//Byte select
					16'h0001: dmem[addra][7:0]      <= dina[7:0];
					16'h0002: dmem[addra][15:8]     <= dina[15:8];
					16'h0004: dmem[addra][23:16]    <= dina[23:16];
					16'h0008: dmem[addra][31:24]    <= dina[31:24];
					
					16'h0010: dmem[addra][39:32]    <= dina[39:32];
					16'h0020: dmem[addra][47:40]    <= dina[47:40];
					16'h0040: dmem[addra][55:48]    <= dina[55:48];
					16'h0080: dmem[addra][63:56]    <= dina[63:56];
					
					16'h0100: dmem[addra][71:64]    <= dina[71:64];
					16'h0200: dmem[addra][79:72]    <= dina[79:72];
					16'h0400: dmem[addra][87:80]    <= dina[87:80];
					16'h0800: dmem[addra][95:88]    <= dina[95:88];
					
					16'h1000: dmem[addra][103:96]   <= dina[103:96];
					16'h2000: dmem[addra][111:104]  <= dina[111:104];
					16'h4000: dmem[addra][119:112]  <= dina[119:112];
					16'h8000: dmem[addra][127:120]  <= dina[127:120];
					
					16'hffff: dmem[addra][127:0]	<= dina[127:0];
					default: ;
				endcase
			end
		end //end always
		
		assign	douta = dmem[addra];
		
endmodule

module blockRam_memory #(parameter WIDTH = 128)(
			clk,
			ena,
			wea,
			addra,
			dina,
			douta
		);
		
		input 						clk;
		input						ena;
		input	[15:0]				wea;
		input	[9:0]				addra;
		input	[WIDTH-1:0]			dina;
		output	[WIDTH-1:0]			douta;
		
		reg [WIDTH-1:0] dmem[1023:0];
		initial begin 	
        $readmemh("G:/Vivado_data/PPC_Cache/PPC_Cache.srcs/sources_1/new/memory_data.mem",dmem);
        $display("0x00: %h", dmem[10'b0000000000]);
                $display("0x01: %h", dmem[10'b0000000001]);
                $display("0x55: %h", dmem[10'b0000000010]);
                $display("0x56: %h", dmem[10'b0000000011]);
        end
		always @(posedge clk) begin
			if(ena) begin
				case(wea)
					//word select
					16'h000f: dmem[addra][31:0]    <= dina[31:0];
					16'h00f0: dmem[addra][63:32]   <= dina[63:32];
					16'h0f00: dmem[addra][95:64]   <= dina[95:64];
					16'hf000: dmem[addra][127:96]  <= dina[127:96];
					//half word select
					16'h0003: dmem[addra][15:0]     <= dina[15:0];
					16'h000c: dmem[addra][31:16]    <= dina[31:16];
					16'h0030: dmem[addra][47:32]    <= dina[47:32];
					16'h00c0: dmem[addra][63:48]    <= dina[63:48];
					16'h0300: dmem[addra][79:64]    <= dina[79:64];
					16'h0c00: dmem[addra][95:80]    <= dina[95:80];
					16'h3000: dmem[addra][111:96]   <= dina[111:96];
					16'hc000: dmem[addra][127:112]  <= dina[127:112];
					//Byte select
					16'h0001: dmem[addra][7:0]      <= dina[7:0];
					16'h0002: dmem[addra][15:8]     <= dina[15:8];
					16'h0004: dmem[addra][23:16]    <= dina[23:16];
					16'h0008: dmem[addra][31:24]    <= dina[31:24];
					
					16'h0010: dmem[addra][39:32]    <= dina[39:32];
					16'h0020: dmem[addra][47:40]    <= dina[47:40];
					16'h0040: dmem[addra][55:48]    <= dina[55:48];
					16'h0080: dmem[addra][63:56]    <= dina[63:56];
					
					16'h0100: dmem[addra][71:64]    <= dina[71:64];
					16'h0200: dmem[addra][79:72]    <= dina[79:72];
					16'h0400: dmem[addra][87:80]    <= dina[87:80];
					16'h0800: dmem[addra][95:88]    <= dina[95:88];
					
					16'h1000: dmem[addra][103:96]   <= dina[103:96];
					16'h2000: dmem[addra][111:104]  <= dina[111:104];
					16'h4000: dmem[addra][119:112]  <= dina[119:112];
					16'h8000: dmem[addra][127:120]  <= dina[127:120];
					
					16'hffff: dmem[addra][127:0]	<= dina[127:0];
					default: ;
				endcase
			end
		end //end always
		
		assign	douta = dmem[addra];
		
endmodule				

module blockRam_flag #(parameter WIDTH = 24)(
			clk,
			ena,
			wea,
			addra,
			dina,
			douta
		);
		
		input 						clk;
		input						ena;
		input	[2:0]				wea;
		input	[9:0]				addra;
		input	[WIDTH-1:0]			dina;
		output	[WIDTH-1:0]			douta;
		
		reg [WIDTH-1:0] dmem[1023:0];
		initial begin 	
         $readmemh("G:/Vivado_data/PPC_Cache/PPC_Cache.srcs/sources_1/new/tag_data.mem",dmem);
        end
		always @(posedge clk) begin
			if(ena) begin
				case(wea)
					3'b111: dmem[addra][23:0]	<= dina[23:0];
					default: ;
				endcase
			end
		end //end always
		
		assign	douta = dmem[addra];
		
endmodule
					
					
				
				