module lda #(
    localparam bit UseFFs = 1'b1,
    localparam int DIMS = 6,
    localparam int CLASSES = 3,
    localparam type T = logic [15:0]
)
(
    input clk_i, rstn_i,
    input T din [DIMS],
    input T w [DIMS] [CLASSES],
    input T c [CLASSES],
    output logic [CLASSES-1:0] dout
);

T DIN [DIMS];
T W [DIMS] [CLASSES];
T C [CLASSES];
logic [CLASSES-1:0] DOUT, _dout;
if (UseFFs) begin : gen_use_ffs
    always_ff @(posedge clk_i) begin
        DIN <= din;
        W <= w;
        C <= c;
        DOUT <= _dout;
    end
end else begin : gen_dont_use_ffs
    assign DIN = din;
    assign W = w;
    assign C = c;
    assign DOUT = _dout;
end

T temp [CLASSES];
always_comb begin
    int votes [CLASSES];
    _dout = '0;
    for (int j = 0; j < CLASSES; ++j) begin
        votes[j] = 0;
        temp[j] = 0;
        for (int i = 0; i < DIMS; ++i) begin
            temp[j] += DIN[i] * W[j][i];
        end
    end
    if (temp[0] > C[0])
        votes[1] += 1;
    else
        votes[0] += 1;
    if (temp[1] > C[1])
        votes[2] += 1;
    else
        votes[0] += 1;
    if (temp[2] > C[2])
        votes[2] += 1;
    else
        votes[0] += 1;
    if (votes[0] > votes[1] && votes[0] > votes[2])
        _dout[0] = 1'b1;
    else if (votes[1] > votes[2])
        _dout[1] = 1'b1;
    else
        _dout[2] = 1'b1;
end
assign dout = DOUT;
endmodule
