module LUT(
  input       [ 3:0] label_index,
  output logic[ 9:0] Target
  );
always_comb
  case(label_index)
    4'd0:    Target = 10'd81;
    4'd1:    Target = 10'd90;
    4'd2:    Target = 10'd126;
    4'd3:    Target = 10'd133;
    4'd4:    Target = 10'd140;
    4'd5:    Target = 10'd144;
    4'd6:    Target = 10'd183;
    default: Target = 10'd183;
  endcase
endmodule