module top;

logic pclk;
logic presetn;
logic psel;
logic penable;
logic pwrite;
logic [31:0] paddr;
logic [31:0] pwdata;
wire [31:0] prdata;
wire pready;
wire pslverr;

// master (тестовая последовательность)
apb_master master
(
    .pclk(pclk),
    .presetn(presetn),
    .pready(pready),
    .prdata(prdata),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata)
);

// slave (проверяемое устройство)
apb_slave slave
(
    .pclk(pclk),
    .presetn(presetn),
    .paddr(paddr),
    .pwdata(pwdata),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .pready(pready),
    .pslverr(pslverr),
    .prdata(prdata)
);

// тактовый сигнал
always #10 pclk = ~pclk;

// сигналы clk и reset
initial
begin
    pclk = 0;
    presetn = 1'b1;
    repeat (5) @(posedge pclk);
    presetn = 1'b0;
    repeat (5) @(posedge pclk);
    presetn = 1'b1;
end

initial
begin
    $monitor("APB IF state: PENABLE=%b PREADY=%b PADDR=0x%h PWDATA=0x%h PRDATA=0x%h", penable, pready, paddr, pwdata, prdata);
end

endmodule
