module apb_master
(
    input pclk,                    // синхросигнал
    input presetn,                 // сброс (инверсный)
    input pready,                  // готовность от slave
    input [31:0] prdata,           // данные от slave
    output logic psel,             // выбор устройства
    output logic penable,          // вторая фаза обмена
    output logic pwrite,           // 1 - запись, 0 - чтение
    output logic [31:0] paddr,     // адрес
    output logic [31:0] pwdata     // данные для записи
);

parameter p_device_offset = 32'h7000_0000;

logic [31:0] address;
logic [31:0] data_to_device;
logic [31:0] data_from_device;

// запись по APB
task apb_write(input [31:0] addr, [31:0] data);
    wait ((penable==0) && (pready == 0));
    @(posedge pclk);
    psel <= 1'b1;
    paddr[31:0] <= addr[31:0];
    pwdata[31:0] <= data[31:0];
    pwrite <= 1'b1;
    @(posedge pclk);
    penable <= 1'b1;
    @(posedge pclk);
    wait (pready == 1'b1);
    @(posedge pclk);
    psel <= 1'b0;
    penable <= 1'b0;
    pwrite <= 1'b0;
    @(posedge pclk);
endtask

// чтение по APB
task apb_read(input [31:0] addr, output logic [31:0] data);
    wait ((penable==0) && (pready == 0));
    @(posedge pclk);
    psel <= 1'b1;
    pwrite <= 1'b0;
    paddr[31:0] <= addr[31:0];
    @(posedge pclk);
    penable <= 1'b1;
    @(posedge pclk);
    wait (pready == 1'b1);
    @(posedge pclk);
    data[31:0] <= prdata[31:0];
    psel <= 1'b0;
    penable <= 1'b0;
    @(posedge pclk);
endtask

// тестовая последовательность
initial
begin
    psel = '0;
    penable = '0;
    pwrite = '0;
    paddr = '0;
    pwdata = '0;

    // ждём, пока пройдёт сброс
    wait (presetn == 1'b0);
    wait (presetn == 1'b1);
    repeat (5) @(posedge pclk);

    address = p_device_offset + 32'h0;
    data_to_device = 32'h0000_0004;
    apb_write(address, data_to_device);
    apb_read(address, data_from_device);
    $display("Addr= 0x%h, write data 0x%h, read data 0x%h", address, data_to_device, data_from_device);

    address = p_device_offset + 32'h4;
    data_to_device = 32'h3110_2026;
    apb_write(address, data_to_device);
    apb_read(address, data_from_device);
    $display("Addr= 0x%h, write data 0x%h, read data 0x%h", address, data_to_device, data_from_device);

    address = p_device_offset + 32'h8;
    data_to_device = 32'h5A69_6E6F;
    apb_write(address, data_to_device);
    apb_read(address, data_from_device);
    $display("Addr= 0x%h, write data 0x%h, read data 0x%h", address, data_to_device, data_from_device);

    address = p_device_offset + 32'hC;
    data_to_device = 32'h4576_6765;
    apb_write(address, data_to_device);
    apb_read(address, data_from_device);
    $display("Addr= 0x%h, write data 0x%h, read data 0x%h", address, data_to_device, data_from_device);

    repeat (10) @(posedge pclk);
    $stop();
end

endmodule
