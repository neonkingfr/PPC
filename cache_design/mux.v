//mux4
module mux_Word4 #(parameter WIDTH = 32)
				(d0,d1,d2,d3,
				 s,y);
		input		[WIDTH-1:0] d0,d1,d2,d3;
		input		[1:0]			s;
		output		[WIDTH-1:0]	y;
		
		reg			[WIDTH-1:0]	y_temp;
		
		always @(*) begin
			case(s)
				2'b00: y_temp = d0;
				2'b01: y_temp = d1;
				2'b10: y_temp = d2;
				2'b11: y_temp = d3;
				default: ;
			endcase
		end // end always
		
		assign  y = y_temp;
endmodule

//mux2
module mux_Word2 #(parameter WIDTH = 32)
				(d0,d1,
				 s,y);
		input		[WIDTH-1:0] d0,d1;
		input						s;
		output	[WIDTH-1:0]	y;
		
		assign  y = (s==1'b1)? d1:d0;
		
endmodule

module mux_Word2_28 #(parameter WIDTH = 28)
				(d0,d1,
				 s,y);
		input		[WIDTH-1:0] d0,d1;
		input						s;
		output	[WIDTH-1:0]	y;
		
		assign  y = (s==1'b1)? d1:d0;
		
endmodule
