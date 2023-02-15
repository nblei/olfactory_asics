module mlp
(
    input logic [7:0] din [6],
    input logic [7:0] w1  [6]  [16],
    input logic [7:0] b1       [16],
    input logic [7:0] w2  [16] [3],
    input logic [7:0] b2       [3],
    output logic [7:0] dout    [3]
);

logic [7:0] d1 [16];

dense_layer #(.T(logic [7:0]), .D1(6), .D2(16)) layer_1
(
    .din(din),
    .weights(w1),
    .biases(b1),
    .dout(d1)
);

dense_layer #(.T(logic [7:0]), .D1(16), .D2(3)) layer_2
(
    .din(d1),
    .weights(w2),
    .biases(b2),
    .dout(dout)
);

endmodule : mlp
