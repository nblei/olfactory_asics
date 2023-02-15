module angledist
#(
    localparam type T = logic [15:0],
    localparam int DIM = 6,
    localparam bit UseFFs
)
(
    input T din [2] [DIM],
    input T a, b, c,
    output T dout
);

T DIN [2] [DIM];
T A, B, C;
T DOUT, _dout;
assign dout = DOUT;
always_ff @(posedge clk_i) begin
    DIN <= din;
    A <= a;
    B <= b;
    C <= c;
    DOUT <= _dout;
end

T sum, msqsum, vsqum;
always_comb begin
    sum = 0;
    msqsum = 0;
    vsqsum = 0;
    for (int i = 0; i < DIM; ++i) begin
        sum += DIN[0][i] * DIN[1][i];
        msqsum += DIN[0][i] * DIN[0][i];
        vsqsum += DIN[1][i] * DIN[1][i];
    end
end

T mag_prod;
DW_sqrt #(32, 0) u_sqrt1(.a(msqsum*vsqsum), .root(mag_prod));
// DW_sqrt #(16, 0) u_sqrt2(.a(vsqsum), .root(mag_v));
T arcos_val, arcos_val_sqd;
assign arcos_val = sum / mag_prod;
assign arcos_val_sqd = arcos_val * arcos_val;
assign _dout = arcos_val_sqd * A + arcos_val * B + C;
// double acos(x) {
//    return (-0.69813170079773212 * x * x - 0.87266462599716477) * x + 1.5707963267948966;
// }
endmodule : angledist
