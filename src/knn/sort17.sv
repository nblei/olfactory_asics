
module sort17
#(
    parameter type T = logic [31:0],
    localparam type I = logic [$clog2(17)-1:0]
)
(
    input T din [17],
    output I dout [17]
);

function automatic swap(inout T a, inout T b, inout I ai, inout I bi);
    T temp;
    I tempi;
    if (b < a) begin
        temp = b;
        b = a;
        a = temp;
        tempi = bi;
        bi = ai;
        ai = tempi;
    end
endfunction : swap

T x[17];
I y[17];
assign dout = y;
always_comb begin
    x = din;
    for (int i = 0; i < 17; ++i) y[i] = i;
    swap(x[0], x[11], y[0], y[11]);
    swap(x[1], x[15], y[1], y[15]);
    swap(x[2], x[10], y[2], y[10]);
    swap(x[3], x[5], y[3], y[5]);
    swap(x[4], x[6], y[4], y[6]);
    swap(x[8], x[12], y[8], y[12]);
    swap(x[9], x[16], y[9], y[16]);
    swap(x[13], x[14], y[13], y[14]);
    swap(x[0], x[6], y[0], y[6]);
    swap(x[1], x[13], y[1], y[13]);
    swap(x[2], x[8], y[2], y[8]);
    swap(x[4], x[14], y[4], y[14]);
    swap(x[5], x[15], y[5], y[15]);
    swap(x[7], x[11], y[7], y[11]);
    swap(x[0], x[8], y[0], y[8]);
    swap(x[3], x[7], y[3], y[7]);
    swap(x[4], x[9], y[4], y[9]);
    swap(x[6], x[16], y[6], y[16]);
    swap(x[10], x[11], y[10], y[11]);
    swap(x[12], x[14], y[12], y[14]);
    swap(x[0], x[2], y[0], y[2]);
    swap(x[1], x[4], y[1], y[4]);
    swap(x[5], x[6], y[5], y[6]);
    swap(x[7], x[13], y[7], y[13]);
    swap(x[8], x[9], y[8], y[9]);
    swap(x[10], x[12], y[10], y[12]);
    swap(x[11], x[14], y[11], y[14]);
    swap(x[15], x[16], y[15], y[16]);
    swap(x[0], x[3], y[0], y[3]);
    swap(x[2], x[5], y[2], y[5]);
    swap(x[6], x[11], y[6], y[11]);
    swap(x[7], x[10], y[7], y[10]);
    swap(x[9], x[13], y[9], y[13]);
    swap(x[12], x[15], y[12], y[15]);
    swap(x[14], x[16], y[14], y[16]);
    swap(x[0], x[1], y[0], y[1]);
    swap(x[3], x[4], y[3], y[4]);
    swap(x[5], x[10], y[5], y[10]);
    swap(x[6], x[9], y[6], y[9]);
    swap(x[7], x[8], y[7], y[8]);
    swap(x[11], x[15], y[11], y[15]);
    swap(x[13], x[14], y[13], y[14]);
    swap(x[1], x[2], y[1], y[2]);
    swap(x[3], x[7], y[3], y[7]);
    swap(x[4], x[8], y[4], y[8]);
    swap(x[6], x[12], y[6], y[12]);
    swap(x[11], x[13], y[11], y[13]);
    swap(x[14], x[15], y[14], y[15]);
    swap(x[1], x[3], y[1], y[3]);
    swap(x[2], x[7], y[2], y[7]);
    swap(x[4], x[5], y[4], y[5]);
    swap(x[9], x[11], y[9], y[11]);
    swap(x[10], x[12], y[10], y[12]);
    swap(x[13], x[14], y[13], y[14]);
    swap(x[2], x[3], y[2], y[3]);
    swap(x[4], x[6], y[4], y[6]);
    swap(x[5], x[7], y[5], y[7]);
    swap(x[8], x[10], y[8], y[10]);
    swap(x[3], x[4], y[3], y[4]);
    swap(x[6], x[8], y[6], y[8]);
    swap(x[7], x[9], y[7], y[9]);
    swap(x[10], x[12], y[10], y[12]);
    swap(x[5], x[6], y[5], y[6]);
    swap(x[7], x[8], y[7], y[8]);
    swap(x[9], x[10], y[9], y[10]);
    swap(x[11], x[12], y[11], y[12]);
    swap(x[4], x[5], y[4], y[5]);
    swap(x[6], x[7], y[6], y[7]);
    swap(x[8], x[9], y[8], y[9]);
    swap(x[10], x[11], y[10], y[11]);
    swap(x[12], x[13], y[12], y[13]);
end

endmodule : sort17
