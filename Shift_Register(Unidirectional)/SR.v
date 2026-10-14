module top #(
    parameter width= 4
) (
    input serial_in,
    input clk,
    input En,
    output serial_out,
    output reg [width-1:0] q=0
);
  
    always @(posedge clk) begin
        
            if(En)  begin
            q<={serial_in,q[width-1:1]};
            end
    end

    assign serial_out=q[0];

endmodule