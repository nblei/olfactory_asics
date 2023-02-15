
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
end

endmodule : sort17
