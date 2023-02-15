
module sort17
#(localparam type T = logic [31:0])
(
    input T din [17],
    output T dout [17]
);

function automatic swap(inout T a, inout T b);
    T temp;
    if (b < a) begin
        temp = b;
        b = a;
        a = b;
    end
endfunction : swap

T x[17];
assign dout = x;
always_comb begin
    x = din;
    swap(x[0], x[11]);
    swap(x[1], x[15]);
    swap(x[2], x[10]);
    swap(x[3], x[5]);
    swap(x[4], x[6]);
    swap(x[8], x[12]);
    swap(x[9], x[16]);
    swap(x[13], x[14]);
    swap(x[0], x[6]);
    swap(x[1], x[13]);
    swap(x[2], x[8]);
    swap(x[4], x[14]);
    swap(x[5], x[15]);
    swap(x[7], x[11]);
    swap(x[0], x[8]);
    swap(x[3], x[7]);
    swap(x[4], x[9]);
    swap(x[6], x[16]);
    swap(x[10], x[11]);
    swap(x[12], x[14]);
    swap(x[0], x[2]);
    swap(x[1], x[4]);
    swap(x[5], x[6]);
    swap(x[7], x[13]);
    swap(x[8], x[9]);
    swap(x[10], x[12]);
    swap(x[11], x[14]);
    swap(x[15], x[16]);
    swap(x[0], x[3]);
    swap(x[2], x[5]);
    swap(x[6], x[11]);
    swap(x[7], x[10]);
    swap(x[9], x[13]);
    swap(x[12], x[15]);
    swap(x[14], x[16]);
    swap(x[0], x[1]);
    swap(x[3], x[4]);
    swap(x[5], x[10]);
    swap(x[6], x[9]);
    swap(x[7], x[8]);
    swap(x[11], x[15]);
    swap(x[13], x[14]);
    swap(x[1], x[2]);
    swap(x[3], x[7]);
    swap(x[4], x[8]);
    swap(x[6], x[12]);
    swap(x[11], x[13]);
    swap(x[14], x[15]);
    swap(x[1], x[3]);
    swap(x[2], x[7]);
    swap(x[4], x[5]);
    swap(x[9], x[11]);
    swap(x[10], x[12]);
    swap(x[13], x[14]);
    swap(x[2], x[3]);
    swap(x[4], x[6]);
    swap(x[5], x[7]);
    swap(x[8], x[10]);
    swap(x[3], x[4]);
    swap(x[6], x[8]);
    swap(x[7], x[9]);
    swap(x[10], x[12]);
    swap(x[5], x[6]);
    swap(x[7], x[8]);
    swap(x[9], x[10]);
    swap(x[11], x[12]);
    swap(x[4], x[5]);
    swap(x[6], x[7]);
    swap(x[8], x[9]);
    swap(x[10], x[11]);
    swap(x[12], x[13]);
end

endmodule : sort17
