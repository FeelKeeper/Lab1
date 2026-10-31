module apb_slave
(
    input pclk, //синхросигнал
    input presetn, //сигнал сброса (инверсный)
    input [31:0] paddr, //адрес обращения
    input [31:0] pwdata, //данные для записи
    input psel, // признак выбора устройсва
    input penable, //признак активной транзакции
    input pwrite, // признак операции записи
    output logic pready, // признак готовности от устройства
    output logic pslverr, // опциональный сигнал: признак ошибки при обращении
    output logic [31:0] prdata // прочитанные данные
);
    logic [31:0] register_with_some_name;
    logic [31:0] reg_num;       // адрес 0x0: номер в списке
    logic [31:0] reg_date;      // адрес 0x4: дата
    logic [31:0] reg_surname;   // адрес 0x8: фамилия
    logic [31:0] reg_name;      // адрес 0xC: имя
    //APB FSM
    enum logic [1:0] {
        APB_SETUP,
        APB_W_ENABLE,
        APB_R_ENABLE
    } apb_st;
	 
    always @(posedge pclk)
        if (!presetn)
        begin
            prdata <= '0;
            pslverr <= 1'b0;
            pready <= 1'b0;
            register_with_some_name <= 32'h0;
            reg_num <= 32'h0;
            reg_date <= 32'h0;
            reg_surname <= 32'h0;
            reg_name <= 32'h0;
            apb_st <= APB_SETUP;
        end
        else
        begin
            case(apb_st)
                APB_SETUP:
                begin: apb_setup_st
                    // clear the prdata and error
                    prdata <= '0;
                    pready <= 1'b0;
                    pslverr <= 1'b0;
                    // Move to ENABLE when the psel is asserted
                    if (psel && !penable)
                    begin
                        if (pwrite == 1'b1)
                        begin
                            apb_st <= APB_W_ENABLE;
                        end
                        else
                        begin
                            apb_st <= APB_R_ENABLE;
                        end
                    end
                end: apb_setup_st
                APB_W_ENABLE:
                begin: apb_w_en_st
                    // decode address and write
                    if (psel && penable && pwrite)
                    begin
                        pready <= 1'b1;
                        case (paddr[7:0])
                            8'h0: begin
                                reg_num <= pwdata;
								// if (pwdata[0] == 1'b0)
								// begin
								// 	register_with_some_name <=32'hAAAA_AAAA;
								// end
								// else
								// begin
								// 	register_with_some_name <=32'h5555_5555;
								// end
                                $display("SLAVE: WRITE addr=%h data=%h", paddr, pwdata);
                                // запись в регистр со смещением 0
                                //register_with_some_name <= pwdata;
                                // и/или обработка записи в регистр для выполнения каких-либо действий (может быть здесь или за пределами FSM APB)
                                // if (pwdata[.....] == ..... )
                                // begin
                                // ......
                                // end
                            end
                            8'h4: begin
                                // запись в регистр со смещением 4
                                reg_date <= pwdata;
                                $display("SLAVE: WRITE addr=%h data=%h", paddr, pwdata);
                            end
                            8'h8: begin
                                // запись в регистр со смещением 8
                                reg_surname <= pwdata;
                                $display("SLAVE: WRITE addr=%h data=%h", paddr, pwdata);
                            end
                            8'hC: begin
                                //запись в регистр со смещением 12
                                reg_name <= pwdata;
                                $display("SLAVE: WRITE addr=%h data=%h", paddr, pwdata);
                            end
                            default:
                            begin
                                pslverr <= 1'b1;
                            end
                        endcase
                        apb_st <= APB_SETUP;
                    end
                end: apb_w_en_st
                APB_R_ENABLE:
                begin: apb_r_en_st
                    if (psel && penable && !pwrite)
                    begin
                        pready <= 1'b1;
                        case (paddr[7:0])
                            8'h0: begin
                                // чтение из регистра со смещением 0
                                prdata[31:0] <= reg_num;
                                $display("SLAVE: READ addr=%h data=%h", paddr, reg_num);
                            end
                            8'h4: begin
                                // чтение из регистра со смещением 4
                                prdata[31:0] <= reg_date;
                                $display("SLAVE: READ addr=%h data=%h", paddr, reg_date);
                            end
                            8'h8: begin
                                // чтение из регистра со смещением 8
                                prdata[31:0] <= reg_surname;
                                $display("SLAVE: READ addr=%h data=%h", paddr, reg_surname);
                            end
                            8'hC: begin
                                //чтение из регистра со смещением 12
                                prdata[31:0] <= reg_name;
                                $display("SLAVE: READ addr=%h data=%h", paddr, reg_name);
                            end
                            default:
                            begin
                                pslverr <= 1'b1;
                            end
                        endcase
                        apb_st <= APB_SETUP;
                    end
                end: apb_r_en_st
                default:
                begin
                    pslverr <= 1'b1;
                end
            endcase
            // можем выполнить какие-то действия здесь
            //if (penable==1'b0)
            
        end // закончился блок внутри always
endmodule