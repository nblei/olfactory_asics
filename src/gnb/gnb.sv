module gnb
#(
    parameter type T = logic [15:0],
    parameter int DIMS = 6,
    parameter int CLASSES = 3,
    parameter bit UseFFs = 1'b1
)
(
    input clk_i, rstn_i,
    input  T din      [DIMS],
    input  T theta    [CLASSES] [DIMS],
    input  T sigma    [CLASSES] [DIMS],
    input  T logsigma [CLASSES] [DIMS],
    input  T beta     [CLASSES],
    output logic [CLASSES-1:0] dout
);

T DIN                [DIMS];
T THETA    [CLASSES] [DIMS];
T SIGMA    [CLASSES] [DIMS];
T LOGSIGMA [CLASSES] [DIMS];
T BETA     [CLASSES]       ;
logic [CLASSES-1:0] _dout, DOUT;

if (UseFFs) begin : gen_use_ffs
    always_ff @(posedge clk_i) begin
        DIN <= din;
        THETA <= theta;
        SIGMA <= sigma;
        LOGSIGMA <= logsigma;
        BETA <= beta;
        DOUT <= _dout;
    end
end else begin : gen_dont_use_ffs
    assign DIN = din;
    assign THETA = theta;
    assign SIGMA = sigma;
    assign LOGSIGMA = logsigma;
    assign BETA = beta;
    assign DOUT = _dout;
end

T votes [CLASSES];
for (genvar i = 0; i < CLASSES; ++i) begin : gen_gauss
    T gauss_results;
    gnb_gauss #(.T(T), .DIMS(DIMS)) u_gnb_gauss(
            .din(DIN),
            .theta(THETA[i]),
            .sigma(SIGMA[i]),
            .dout(gauss_results)
        );
    assign votes[i] = BETA[i] - gauss_results;
end

always_comb begin
    _dout = '0;
    if (votes[0] > votes[1] && votes[0] > votes[2])
        _dout[0] = 1'b1;
    else if (votes[1] > votes[2])
        _dout[1] = 1'b1;
    else
        _dout[2] = 1'b1;
end

assign dout = DOUT;


endmodule : gnb
