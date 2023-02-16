module svm
#(
    localparam type T = logic[15:0],
    localparam int DIMS = 21,
    localparam int INTER = 6,
    localparam int CLASSES = 3,
    localparam type TC = logic[$clog2(CLASSES)-1:0]
)
(
    input clk_i, rstn_i,
    input  T feats [DIMS][INTER],
    input  T biases      [INTER],
    input  T feats2 [INTER][CLASSES],
    input  T biases2       [CLASSES],
    input  T din   [DIMS],
    output TC class_o
);

T FEATS [DIMS][INTER];
T DIN   [DIMS];
T BIASES      [INTER];
T FEATS2  [INTER][CLASSES];
T BIASES2        [CLASSES];
T matprod     [CLASSES];
T matprodi    [INTER];
TC CLASS, _class;
assign class_o = CLASS;

always_ff @(posedge clk_i) begin
    FEATS <= feats;
    DIN <= din;
    BIASES <= biases;
    BIASES2 <= biases2;
    FEATS2 <= feats2;
    CLASS <= _class;
end

mlp_layer #(.D1(DIMS), .D2(INTER)) u_matmul1
(
    .din(DIN),
    .weights(FEATS),
    .biases(BIASES),
    .dout(matprodi)
);

mlp_layer #(.D1(DIMS), .D2(INTER)) u_matmul2
(
    .din(matprodi),
    .weights(FEATS2),
    .biases(BIASES2),
    .dout(matprod)
);

TC votes [CLASSES];
always_comb begin
    for (int c = 0; c < CLASSES; ++c) votes[c] = 0;
    votes[$signed(matprod[0]) > 0 ? 0 : 1] += 1;
    votes[$signed(matprod[1]) > 0 ? 0 : 2] += 1;
    votes[$signed(matprod[2]) > 0 ? 1 : 2] += 1;
end

assign _class = votes[0] > votes[1] ?
                    (votes[0] > votes[2] ? 0 : 2) :
                    (votes[1] > votes[2] ? 1 : 2);

endmodule : svm
