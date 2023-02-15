module lda #(
    localparam int DIMS = 6,
    localparam int CLASSES = 3,
    localparam type T = logic [7:0]
)
(
    input clk_i, rstn_i,
    input T din [DIMS],
    input T w [DIMS] [CLASSES],
    input T c [CLASSES],
    output logic [CLASSES-1:0] dout
);

// Compute inner products
T temp [CLASSES];
always_comb begin
    int votes [CLASSES];
    dout = '0;
    for (int j = 0; j < CLASSES; ++j) begin
        votes[j] = 0;
        temp[j] = 0;
        for (int i = 0; i < DIMS; ++i) begin
            temp[j] += din[i] * w01[j][i];
        end
    end
    if (temp[0] > c[0])
        votes[1] += 1;
    else
        votes[0] += 1;
    if (temp[1] > c[1])
        votes[2] += 1;
    else
        votes[0] += 1;
    if (temp[2] > c[2])
        votes[2] += 1;
    else
        votes[0] += 1;
    if (votes[0] > votes[1] && votes[0] > votes[2])
        dout[0] = 1'b1;
    else if (votes[1] > votes[2])
        dout[1] = 1'b1;
    else
        dout[2] = 1'b1;
end

endmodule
