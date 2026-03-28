module Mux_2to1 (
    input  logic        sel,
    input  logic [31:0] in1,
    input  logic [31:0] in2,
    output logic [31:0] out
);
    always_comb begin
        out = sel ? in2 : in1;
    end
endmodule

module Mux_3to1 (
    input  logic [1:0]  sel,
    input  logic [31:0] in1,
    input  logic [31:0] in2,
    input  logic [31:0] in3,
    output logic [31:0] out
);
    always_comb begin
        case (sel)
            2'd0:    out = in1;
            2'd1:    out = in2;
            2'd2:    out = in3;
            default: out = 32'b0;
        endcase
    end
endmodule
