module gnb_gauss #(
    parameter type T = logic [15:0],
    parameter int DIMS = 6
)
(
    input  T din   [DIMS],
    input  T theta [DIMS],
    input  T sigma [DIMS],
    output T dout
);

always_comb begin
    T temp;
    dout = 0;
    for (int i = 0; i < DIMS; ++i) begin
        temp = (din[i] - theta[i]) * sigma[i];
        temp = (temp < 0) ? -temp : temp;
        dout += temp;
    end
end

endmodule : gnb_gauss
