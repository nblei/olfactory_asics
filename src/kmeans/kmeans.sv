module kmeans
#(
    localparam type T = logic [15:0],
    localparam type DT = logic [31:0],
    localparam int K = 3,
    localparam int DIMS = 6,
    localparam int SAMPS = 128,
    localparam type M = logic [$clog2(SAMPS)-1:0],
    localparam type TX = logic [15+$clog2(SAMPS):0],
    localparam type TK = logic [$clog2(K)-1:0]
)
(
    input clk_i, input rstn_i, start_i,
    input T membus_i [DIMS],
    output M addr_o,
    output TK class_o
);

typedef enum {
    Idle,
    InitializeCentroids,
    ComputeCentroids,
    UpdateClusters,
    Classify
} phase_t;

typedef struct packed {
    phase_t phase;
    M sample_counter;
} state_t;

M sample_counter_pp;
state_t state;
assign sample_counter_pp = state.sample_counter + 1;
T centroids [K] [DIMS];
TX centroids_next [K][DIMS];
localparam type KT = logic [$clog2(K):0];
TK cluster_number;
DT centroid_distances [K];
for (genvar k = 0; k < K; ++k) begin : gen_distances_k
    DT centroid_dim_distances_sqd [DIMS];
    for (genvar dim = 0; dim < DIMS; ++dim) begin : gen_distances_dim
        T dim_dif;
        assign dim_dif = centroids[k][dim] - membus_i[dim];
        assign centroid_dim_distances_sqd [dim] = dim_dif * dim_dif;
    end
    always_comb begin
        centroid_distances [k] = '0;
        for (int dim = 0; dim < DIMS; ++dim) begin
            centroid_distances[k] += centroid_dim_distances_sqd[dim];
        end
    end
end

// BREAKS if K != 3
assign cluster_number = centroid_distances[0] < centroid_distances[1] ?
                        (centroid_distances[0] < centroid_distances[2] ? 0 : 2) :
                        (centroid_distances[1] < centroid_distances[2] ? 1 : 2);

assign addr_o = state.sample_counter;
assign class_o = cluster_number;

// function automatic T
always_ff @(posedge clk_i) begin
    if (!rstn_i) begin
        state.phase <= Idle;
    end else begin
        case (state.phase)
            Idle: begin
                if (start_i) begin
                    state.phase <= InitializeCentroids;
                    state.sample_counter <= 0;
                    // Initialize centroids
                    // Zeroize centroids_next
                    for (int i = 0; i < K; ++i) begin
                        for (int j = 0; j < DIMS; ++j) begin
                            centroids_next[i][j] <= '0;
                        end
                    end
                end
            end
            InitializeCentroids: begin
                for (int dim = 0; dim < DIMS; ++dim) begin
                    centroids[state.sample_counter][dim] <= membus_i[dim];
                end
                state.sample_counter <= sample_counter_pp;
                if (sample_counter_pp == K) begin
                    state.phase <= ComputeCentroids;
                    state.sample_counter <= '0;
                end
            end
            ComputeCentroids: begin
                state.sample_counter <= sample_counter_pp;
                if (sample_counter_pp == 0) begin
                    state.phase <= UpdateClusters;
                end
                for (int dim = 0; dim < DIMS; ++dim) begin
                    centroids_next[cluster_number][dim] += membus_i[dim];
                end
            end
            UpdateClusters: begin
                for (int i = 0; i < K; ++i) begin
                    for (int j = 0; j < DIMS; ++j) begin
                        centroids[i][j] <= centroids_next[i][j] / SAMPS;
                        centroids_next[i][j] <= '0;
                    end
                end
            end
            Classify: ;
            default: ;
        endcase
    end
end

endmodule : kmeans
