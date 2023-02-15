module conv2d
#(
    localparam type T = logic [15:0],
    localparam int R = 3,
    localparam int H = 32,
    localparam int Q = H - (R/2)*2
)
(
    input clk_i, rstn_i,
    input  start_i,
    input  T membus_i [R],
    output T raddr_o,
    output   addr_is_weight_o,
    output T membus_o,
    output T waddr_o,
    output   wen_o
);

typedef enum {
    Idle,
    WLoad,
    FLoad
} state_phase_t;

typedef struct packed {
    state_phase_t phase;
    logic [$clog2(R)-1:0] wload_counter;
    logic [$clog2(H)-1:0] row_counter;
    logic [$clog2(H)-1:0] col_counter;
} state_t;

state_t s;

T weight_buf [R] [R];
T feat_buf [R] [R];
T outval;

always_ff @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        s.phase <= Idle;
        s.wload_counter <= 0;
        s.row_counter <= 0;
        s.col_counter <= 0;
    end else begin
        case (s.phase)
            Idle: begin
                s.wload_counter <= 0;
                if (start_i) s.phase <= WLoad;
            end
            WLoad: begin
                s.wload_counter <= s.wload_counter + 1;
                if (s.wload_counter == R-1) begin
                    s.row_counter <= 0;
                    s.col_counter <= 0;
                    s.phase <= FLoad;
                    // Zeroize Feature Buf
                    for (int row = 0; row < R; ++row) begin
                        for (int col = 0; col < R; ++col) begin
                            feat_buf [row] [col] <= '0;
                        end
                    end
                end
                // Load Weight Buf
                for (int row = 0; row < R; ++row) begin
                    weight_buf [row][0] <= membus_i [row];
                    for (int col = 1; col < R; ++col) begin
                        weight_buf [row][col] <= weight_buf [row][col-1];
                    end
                end
            end
            FLoad: begin
                s.row_counter <= s.row_counter + 1;
                if (s.row_counter == H-1) begin
                    s.row_counter <= '0;
                    s.col_counter <= s.col_counter + 1;
                    if (s.col_counter == H-1) begin
                        s.phase <= Idle;
                        // Zeroize Feature Buf
                        for (int row = 0; row < R; ++row) begin
                            for (int col = 0; col < R; ++col) begin
                                feat_buf [row] [col] <= '0;
                            end
                        end
                    end else begin
                        for (int row = 0; row < R; ++row) begin
                            feat_buf [row][0] <= membus_i [row];
                            for (int col = 1; col < R; ++col) begin
                                feat_buf [row][col] <= feat_buf [row][col-1];
                            end
                        end
                    end
                end
            end
            default: begin
            end
        endcase
    end
end

always_comb begin : output_ctl
    raddr_o = '0;
    addr_is_weight_o = 1'b0;
    membus_o = outval;
    waddr_o = '0;
    wen_o = 1'b0;

    case (s.phase)
        Idle: begin
        end
        WLoad: begin
            addr_is_weight_o = 1'b1;
            raddr_o = s.wload_counter;
        end
        FLoad: begin
            wen_o = 1'b1;
            raddr_o = s.row_counter * H + s.col_counter;
            waddr_o = raddr_o;
        end
        default: begin
        end
    endcase
end

always_comb begin : output_compute
    outval = '0;
    for (int i = 0; i < R; ++i) begin
        for (int j = 0; j < R; ++j) begin
            outval += weight_buf[i][j] * feat_buf[i][j];
        end
    end
end


endmodule : conv2d
