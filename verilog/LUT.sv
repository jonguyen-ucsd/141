module LUT(
  input       [ 3:0] label_index,
  output logic[ 9:0] Target
  );
always_comb
  case(label_index)
    4'd0:    Target = 10'd9;
    4'd1:    Target = 10'd15;
    4'd2:    Target = 10'd23;
    4'd3:    Target = 10'd62;
    4'd4:    Target = 10'd64;
    4'd5:    Target = 10'd111;
    default: Target = 10'd111;
  endcase
endmodule