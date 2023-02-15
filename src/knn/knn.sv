module knn
#(
    localparam type T = logic [31:0],
    localparam int NPoints = 17,
    localparam int Classes = 2,
    localparam type C = logic [$clog2(Classes)-1:0],
    localparam int K = 3,
    localparam bit UseFFs
)
(
    input clk_i, rstn_i,
    input T din,
    input T points [NPoints],
    input C classes [NPoints],
    output C dout
);

typedef struct packed  {
    logic [15:0] x;
    logic [15:0] y;
} point_t;

point_t POINTS [NPoints];
point_t DIN;
T distances [NPoints];
T sorted_distances [NPoints];
C CLASSES [NPoints];
C _dout, DOUT;


always_comb begin
    // Compute squared distances
    for (int i = 0; i < NPoints; ++i) begin
        distances[i] = (points[i].x - din.x)*(points[i].x - din.x) +
                       (points[i].y - din.y)*(points[i].y - din.y);
    end
    // Determine
end

sort17 u_sort17(.din(distances), .dout(sorted_distances));

if (UseFFs) begin : gen_use_ffs
    always_ff @(posedge clk_i) begin
        POINTS <= points;
        CLASSES <= classes;
        DIN <= din;
        DOUT <= _dout;
    end
end else begin : gen_dont_use_ffs
    assign POINTS = points;
    assign CLASSES = classes;
    assign DIN = din;
    assign DOUT = _dout;
end
assign dout = DOUT;

endmodule : knn
