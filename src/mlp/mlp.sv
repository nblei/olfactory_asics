module mlp
#(
    localparam int NBits = 16,
    localparam type T = logic [NBits-1:0],
    localparam bit UseFFs = 1'b1
)
(
    input clk_i, rstn_i,
    input T din [6],
    input T w1  [6]  [16],
    input T b1       [16],
    input T w2  [16] [3],
    input T b2       [3],
    output T dout    [3]
);

T d1 [16];

T W1 [6] [16];
T B1     [16];
T W2 [16] [3];
T B2      [3];
T DIN     [6];
T DOUT [3], _dout    [3];

generate
if (UseFFs != 0) begin : gen_use_ffs
    always_ff @(posedge clk_i) begin
        DIN <= din;
        W1 <= w1;
        W2 <= w2;
        B1 <= b1;
        B2 <= b2;
        DOUT <= _dout;
    end
end else begin : gen_no_ffs
    assign DIN = din;
    assign W1 = w1;
    assign W2 = w2;
    assign B1 = b1;
    assign B2 = b2;
    assign DOUT = _dout;
end
endgenerate

dense_layer #(.NBits(NBits), .T(T), .D1(6), .D2(16)) layer_1
(
    .din(DIN),
    .weights(W1),
    .biases(B1),
    .dout(d1)
);

dense_layer #(.NBits(NBits), .T(T), .D1(16), .D2(3)) layer_2
(
    .din(d1),
    .weights(W2),
    .biases(B2),
    .dout(_dout)
);
assign dout = DOUT;

endmodule : mlp
