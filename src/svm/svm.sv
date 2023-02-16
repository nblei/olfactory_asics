module svm
#(
    localparam type T = logic[15:0],
    localparam int DIMS = 21,
    localparam int CLASSES = 3,
    localparam type TC = logic[$clog2(CLASSES)-1:0]
)
(
    input clk_i, rstn_i,
    input  T feats [DIMS][CLASSES],
    input  T biases      [CLASSES],
    input  T din   [DIMS],
    output TC class_o
);

T FEATS [DIMS][CLASSES];
T DIN   [DIMS];
T BIASES      [CLASSES];
T matprod     [CLASSES];
TC CLASS, _class;
assign class_o = CLASS;

always_ff @(posedge clk_i) begin
    FEATS <= feats;
    DIN <= din;
    BIASES <= biases;
    CLASS <= _class;
end

mlp_layer #(.D1(DIMS), .D2(CLASSES)) u_matmul
(
    .din(DIN),
    .weights(FEATS),
    .biases(BIASES),
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
