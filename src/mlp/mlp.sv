module mlp
#(
    localparam int UseFFs = 1
)
(
    input clk_i, rstn_i,
    input logic [7:0] din [6],
    input logic [7:0] w1  [6]  [16],
    input logic [7:0] b1       [16],
    input logic [7:0] w2  [16] [3],
    input logic [7:0] b2       [3],
    output logic [7:0] dout    [3]
);

logic [7:0] d1 [16];

logic [7:0] W1 [6] [16];
logic [7:0] B1     [16];
logic [7:0] W2 [16] [3];
logic [7:0] B2      [3];
logic [7:0] DIN     [6];
logic [7:0] DOUT [3], _dout    [3];

// generate
// if (UseFFs != 0) begin : gen_use_ffs
    always_ff @(posedge clk_i) begin
        DIN <= din;
        W1 <= w1;
        W2 <= w2;
        B1 <= b1;
        B2 <= b2;
        DOUT <= _dout;
    end
// end else begin : gen_no_ffs
//     assign DIN = din;
//     assign W1 = w1;
//     assign W2 = w2;
//     assign B1 = b1;
//     assign B2 = b2;
//     assign DOUT = _dout;
// end
// endgenerate

dense_layer #(.T(logic [7:0]), .D1(6), .D2(16)) layer_1
(
    .din(DIN),
    .weights(W1),
    .biases(B1),
    .dout(d1)
);

dense_layer #(.T(logic [7:0]), .D1(16), .D2(3)) layer_2
(
    .din(d1),
    .weights(W2),
    .biases(B2),
    .dout(_dout)
);
assign dout = DOUT;

endmodule : mlp
