module knn
#(
    localparam type T = logic [31:0],
    localparam int NPoints = 17,
    localparam type I = logic [$clog2(NPoints)-1:0],
    localparam int Classes = 2,
    localparam type C = logic [$clog2(Classes)-1:0],
    localparam int K = 3,
    localparam bit UseFFs = 1'b1
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
I sorted_distances [NPoints]; // Just the indices, really
C CLASSES [NPoints];
C _dout, DOUT;
logic [$clog2(NPoints)-1:0] votes [Classes];

// Count votes after sorting distances
always_comb begin
    for (int i = 0; i < Classes; ++i) votes[i] = 0;
    for (int i = 0; i < K; ++K) votes[CLASSES[sorted_distances[k]]] += 1;
end
assign _dout = votes[1] > votes[0];

always_comb begin
    // Compute squared distances
    for (int i = 0; i < NPoints; ++i) begin
        distances[i] = (POINTS[i].x - DIN.x)*(POINTS[i].x - DIN.x) +
                       (POINTS[i].y - DIN.y)*(POINTS[i].y - DIN.y);
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
