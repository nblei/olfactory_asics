module dense_layer
#(
    localparam int NBits = 8,
    parameter type T = logic [NBits-1:0],
    parameter unsigned D1,
    parameter unsigned D2
)
(
    input  T  din     [D1],
    input  T  weights [D1] [D2],
    input  T  biases       [D2],
    output T dout          [D2]

);


T products [D1] [D2];
for (genvar i = 0; i < D1; ++i) begin : gen_products_i
    for (genvar j = 0; j < D2; ++j) begin : gen_products_j
        assign products[i][j] = din[i] * weights[i] [j];
    end
end

T prod_sums [D2];
for (genvar j = 0; j < D2; ++j) begin : gen_prod_sums
    always_comb begin : compute_sum
        prod_sums[j] = 0;
        for (int i = 0; i < D1; ++i)
            prod_sums[j] += products[i][j];
    end
end

T bias_added [D2];
for (genvar i = 0; i < D2; ++i) begin : gen_biases
    assign bias_added[i] = prod_sums[i] + biases[i];
end

for (genvar i = 0; i < D2; ++i) begin : gen_relu
    assign dout[i] = bias_added[i][NBits-1] ? '0 : bias_added[i];
end

endmodule : dense_layer
